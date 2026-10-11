#!/usr/bin/env python3
"""Statically verify the Sysadmin Factorio mod without starting Factorio.

The verifier reads the source tree only.  With ``--installed-mod`` it also
reads an already-copied mod directory and compares a SHA-256 manifest of the
runtime payload; it never installs, removes, or changes either directory.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import Iterable


REQUIRED_INFO_FIELDS = {
    "name": str,
    "version": str,
    "title": str,
    "author": str,
    "description": str,
    "factorio_version": str,
}
ASSET_SUFFIXES = frozenset({".png", ".jpg", ".jpeg", ".ogg", ".wav", ".webp"})
MOD_NAME_RE = re.compile(r"[A-Za-z0-9_-]+\Z")
VERSION_RE = re.compile(r"\d+\.\d+\.\d+\Z")
FACTORIO_VERSION_RE = re.compile(r"\d+\.\d+\Z")
DIRECT_ASSET_RE = re.compile(
    r"(?P<quote>[\"'])__(?P<mod>[A-Za-z0-9_-]+)__/(?P<path>[^\"'\r\n]+)(?P=quote)"
)
PREFIX_ASSIGNMENT_RE = re.compile(
    r"\b(?:local\s+)?(?P<variable>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*"
    r"(?P<quote>[\"'])__(?P<mod>[A-Za-z0-9_-]+)__/(?P<prefix>[^\"'\r\n]*)(?P=quote)"
)


@dataclass(frozen=True)
class AssetReference:
    """One literal mod-local asset path found in a Lua source file."""

    path: str
    source_file: str
    line: int


@dataclass
class VerificationReport:
    """The findings from one read-only verification pass."""

    mod_dir: Path
    info: dict | None = None
    asset_references: list[AssetReference] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    source_manifest: str | None = None
    installed_manifest: str | None = None

    @property
    def ok(self) -> bool:
        return not self.errors

    @property
    def asset_paths(self) -> set[str]:
        return {reference.path for reference in self.asset_references}


def _line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def _is_asset_path(path: str) -> bool:
    return PurePosixPath(path).suffix.lower() in ASSET_SUFFIXES


def _normalise_asset_path(path: str) -> str:
    """Return a safe mod-relative POSIX path or raise ``ValueError``."""

    if "\\" in path:
        raise ValueError("uses a Windows path separator")
    pure_path = PurePosixPath(path)
    if pure_path.is_absolute() or ".." in pure_path.parts:
        raise ValueError("escapes the mod directory")
    if not pure_path.parts or any(part in {"", "."} for part in pure_path.parts):
        raise ValueError("is not a concrete relative path")
    return pure_path.as_posix()


def _iter_lua_files(mod_dir: Path) -> Iterable[Path]:
    return sorted(path for path in mod_dir.rglob("*.lua") if path.is_file())


def discover_asset_references(mod_dir: Path, mod_name: str) -> list[AssetReference]:
    """Find literal local Factorio asset paths used by the current Lua source.

    Factorio asset references use ``__mod-name__/path``.  The POC also keeps a
    local prefix such as ``sprite_path`` and concatenates a literal filename;
    that simple, static form is resolved too.  Dynamic path construction is
    intentionally out of scope for this no-runtime verifier.
    """

    references: list[AssetReference] = []
    for lua_path in _iter_lua_files(mod_dir):
        text = lua_path.read_text(encoding="utf-8")
        source_file = lua_path.relative_to(mod_dir).as_posix()

        for match in DIRECT_ASSET_RE.finditer(text):
            if match.group("mod") != mod_name:
                continue
            path = match.group("path")
            if _is_asset_path(path):
                references.append(
                    AssetReference(path, source_file, _line_number(text, match.start()))
                )

        for assignment in PREFIX_ASSIGNMENT_RE.finditer(text):
            if assignment.group("mod") != mod_name:
                continue
            variable = assignment.group("variable")
            concat_re = re.compile(
                rf"\b{re.escape(variable)}\s*\.\.\s*(?P<quote>[\"'])"
                r"(?P<suffix>[^\"'\r\n]+)(?P=quote)"
            )
            for concat in concat_re.finditer(text):
                path = assignment.group("prefix") + concat.group("suffix")
                if _is_asset_path(path):
                    references.append(
                        AssetReference(path, source_file, _line_number(text, concat.start()))
                    )

    return references


def _load_info(mod_dir: Path, report: VerificationReport) -> dict | None:
    info_path = mod_dir / "info.json"
    if not info_path.is_file():
        report.errors.append("info.json is missing")
        return None

    try:
        info = json.loads(info_path.read_text(encoding="utf-8"))
    except UnicodeDecodeError as error:
        report.errors.append(f"info.json is not UTF-8: {error}")
        return None
    except json.JSONDecodeError as error:
        report.errors.append(f"info.json is not valid JSON: {error.msg} (line {error.lineno})")
        return None

    if not isinstance(info, dict):
        report.errors.append("info.json must contain a JSON object")
        return None

    for field_name, expected_type in REQUIRED_INFO_FIELDS.items():
        value = info.get(field_name)
        if not isinstance(value, expected_type) or not value.strip():
            report.errors.append(f"info.json field {field_name!r} must be a non-empty string")

    name = info.get("name")
    if isinstance(name, str) and name and not MOD_NAME_RE.fullmatch(name):
        report.errors.append("info.json field 'name' contains unsupported characters")

    version = info.get("version")
    if isinstance(version, str) and version and not VERSION_RE.fullmatch(version):
        report.errors.append("info.json field 'version' must use major.minor.patch")

    factorio_version = info.get("factorio_version")
    if (
        isinstance(factorio_version, str)
        and factorio_version
        and not FACTORIO_VERSION_RE.fullmatch(factorio_version)
    ):
        report.errors.append("info.json field 'factorio_version' must use major.minor")

    dependencies = info.get("dependencies")
    if dependencies is not None and (
        not isinstance(dependencies, list)
        or any(not isinstance(dependency, str) or not dependency.strip() for dependency in dependencies)
    ):
        report.errors.append("info.json field 'dependencies' must be a list of non-empty strings")

    return info


def _validate_assets(mod_dir: Path, report: VerificationReport) -> None:
    checked_paths: set[str] = set()
    for reference in report.asset_references:
        if reference.path in checked_paths:
            continue
        checked_paths.add(reference.path)
        try:
            relative_path = _normalise_asset_path(reference.path)
        except ValueError as error:
            report.errors.append(
                f"{reference.source_file}:{reference.line}: asset {reference.path!r} {error}"
            )
            continue

        asset_path = mod_dir.joinpath(*PurePosixPath(relative_path).parts)
        if not asset_path.is_file():
            report.errors.append(
                f"{reference.source_file}:{reference.line}: missing asset {relative_path}"
            )
        elif asset_path.stat().st_size == 0:
            report.errors.append(
                f"{reference.source_file}:{reference.line}: asset {relative_path} is empty"
            )


def _is_runtime_payload_file(relative_path: Path) -> bool:
    """Mirror the installer's ``*.py`` and ``__pycache__`` filters."""

    if any(part in {"__pycache__", ".git"} for part in relative_path.parts):
        return False
    return relative_path.suffix.lower() != ".py"


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def runtime_manifest(mod_dir: Path) -> tuple[str, dict[str, str]]:
    """Return a deterministic hash and per-file hashes for the deployable tree."""

    files: dict[str, str] = {}
    for path in sorted(mod_dir.rglob("*")):
        if not path.is_file():
            continue
        relative_path = path.relative_to(mod_dir)
        if _is_runtime_payload_file(relative_path):
            files[relative_path.as_posix()] = _sha256_file(path)

    digest = hashlib.sha256()
    for relative_path, file_digest in files.items():
        digest.update(relative_path.encode("utf-8"))
        digest.update(b"\0")
        digest.update(file_digest.encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest(), files


def _compare_installed_mod(mod_dir: Path, installed_mod: Path, report: VerificationReport) -> None:
    if not installed_mod.is_dir():
        report.errors.append(f"installed mod directory does not exist: {installed_mod}")
        return

    source_manifest, source_files = runtime_manifest(mod_dir)
    installed_manifest, installed_files = runtime_manifest(installed_mod)
    report.source_manifest = source_manifest
    report.installed_manifest = installed_manifest
    if source_manifest == installed_manifest:
        return

    report.errors.append(
        "installed mod hash mismatch "
        f"(source {source_manifest}, installed {installed_manifest})"
    )
    missing = sorted(set(source_files) - set(installed_files))
    extra = sorted(set(installed_files) - set(source_files))
    changed = sorted(
        path
        for path in set(source_files) & set(installed_files)
        if source_files[path] != installed_files[path]
    )
    for path in missing:
        report.errors.append(f"installed mod is missing runtime file: {path}")
    for path in extra:
        report.errors.append(f"installed mod has extra runtime file: {path}")
    for path in changed:
        report.errors.append(f"installed mod runtime file differs: {path}")


def verify_mod(mod_dir: Path, installed_mod: Path | None = None) -> VerificationReport:
    """Validate metadata and literal local asset references without writing."""

    mod_dir = mod_dir.resolve()
    report = VerificationReport(mod_dir=mod_dir)
    if not mod_dir.is_dir():
        report.errors.append(f"mod directory does not exist: {mod_dir}")
        return report

    report.info = _load_info(mod_dir, report)
    mod_name = report.info.get("name") if report.info else None
    if isinstance(mod_name, str) and mod_name:
        report.asset_references = discover_asset_references(mod_dir, mod_name)
        _validate_assets(mod_dir, report)

    if installed_mod is not None:
        _compare_installed_mod(mod_dir, installed_mod.resolve(), report)
    return report


def _parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--mod-dir",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="source mod directory (default: this script's parent directory)",
    )
    parser.add_argument(
        "--installed-mod",
        type=Path,
        help="existing copied mod directory to compare read-only against the source",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse_args(argv if argv is not None else sys.argv[1:])
    report = verify_mod(args.mod_dir, args.installed_mod)
    if report.errors:
        for error in report.errors:
            print(f"ERROR: {error}")
        return 1

    mod_name = report.info["name"] if report.info else args.mod_dir.name
    print(f"OK: info.json for {mod_name} is valid.")
    print(f"OK: {len(report.asset_paths)} mod-local runtime asset paths resolve.")
    if args.installed_mod is not None:
        print("OK: installed mod runtime manifest matches the source.")
        print(f"SHA-256: {report.source_manifest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
