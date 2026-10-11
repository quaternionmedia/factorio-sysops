"""Positive and negative controls for the read-only Sysadmin mod verifier."""

from __future__ import annotations

import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "sysadmin-poc" / "scripts"))

import verify_mod  # noqa: E402


class VerifyModTests(unittest.TestCase):
    def _make_mod(self, parent: Path, name: str, lua_source: str) -> Path:
        mod_dir = parent / name
        mod_dir.mkdir()
        (mod_dir / "info.json").write_text(
            json.dumps(
                {
                    "name": name,
                    "version": "0.0.1",
                    "title": "Fixture",
                    "author": "Fixture",
                    "description": "Verifier fixture",
                    "factorio_version": "2.0",
                    "dependencies": ["base >= 2.0"],
                }
            ),
            encoding="utf-8",
        )
        (mod_dir / "data.lua").write_text(lua_source, encoding="utf-8")
        return mod_dir

    def test_current_mod_is_a_positive_control(self) -> None:
        report = verify_mod.verify_mod(REPO_ROOT / "sysadmin-poc")

        self.assertTrue(report.ok, report.errors)
        self.assertGreater(len(report.asset_paths), 20)
        self.assertTrue(
            {
                "graphics/icons/basic-server.png",
                "graphics/icons/signals/signal-utilization.png",
                "graphics/entity/basic-server.png",
                "graphics/entity/basic-server-shadow.png",
            }.issubset(report.asset_paths)
        )

    def test_missing_direct_asset_is_a_negative_control(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            mod_dir = self._make_mod(
                Path(temporary_directory),
                "direct-missing",
                'local icon = "__direct-missing__/graphics/missing.png"\n',
            )

            report = verify_mod.verify_mod(mod_dir)

        self.assertFalse(report.ok)
        self.assertIn("data.lua:1: missing asset graphics/missing.png", report.errors)

    def test_prefixed_asset_reference_is_resolved_and_checked(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            mod_dir = self._make_mod(
                Path(temporary_directory),
                "prefix-missing",
                "\n".join(
                    [
                        'local sprite_path = "__prefix-missing__/graphics/entity/"',
                        'local sprite = sprite_path .. "sensor.png"',
                    ]
                ),
            )

            report = verify_mod.verify_mod(mod_dir)

        self.assertIn("graphics/entity/sensor.png", report.asset_paths)
        self.assertIn("data.lua:2: missing asset graphics/entity/sensor.png", report.errors)

    def test_missing_metadata_field_is_a_negative_control(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            mod_dir = self._make_mod(
                Path(temporary_directory),
                "metadata-missing",
                'local icon = "__metadata-missing__/graphics/icon.png"\n',
            )
            (mod_dir / "graphics").mkdir()
            (mod_dir / "graphics" / "icon.png").write_bytes(b"fixture")
            info = json.loads((mod_dir / "info.json").read_text(encoding="utf-8"))
            del info["title"]
            (mod_dir / "info.json").write_text(json.dumps(info), encoding="utf-8")

            report = verify_mod.verify_mod(mod_dir)

        self.assertFalse(report.ok)
        self.assertIn("info.json field 'title' must be a non-empty string", report.errors)

    def test_installed_manifest_comparison_detects_runtime_drift(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            source = self._make_mod(
                temporary_root,
                "hash-source",
                'local icon = "__hash-source__/graphics/icon.png"\n',
            )
            (source / "graphics").mkdir()
            source_asset = source / "graphics" / "icon.png"
            source_asset.write_bytes(b"source asset")
            (source / "scripts").mkdir()
            (source / "scripts" / "developer_only.py").write_text("pass\n", encoding="utf-8")

            installed = temporary_root / "installed-copy"
            shutil.copytree(source, installed)
            (installed / "scripts" / "developer_only.py").unlink()

            matching_report = verify_mod.verify_mod(source, installed)
            installed_asset = installed / "graphics" / "icon.png"
            installed_asset.write_bytes(b"changed asset")
            drift_report = verify_mod.verify_mod(source, installed)

        self.assertTrue(matching_report.ok, matching_report.errors)
        self.assertFalse(drift_report.ok)
        self.assertTrue(
            any("installed mod hash mismatch" in error for error in drift_report.errors),
            drift_report.errors,
        )
        self.assertIn(
            "installed mod runtime file differs: graphics/icon.png",
            drift_report.errors,
        )

    def test_runtime_manifest_matches_the_installer_python_filter(self) -> None:
        self.assertFalse(verify_mod._is_runtime_payload_file(Path("scripts/tool.py")))
        self.assertFalse(
            verify_mod._is_runtime_payload_file(Path("scripts/__pycache__/tool.pyc"))
        )
        self.assertTrue(verify_mod._is_runtime_payload_file(Path("scripts/tool.pyc")))
        self.assertTrue(verify_mod._is_runtime_payload_file(Path("scripts/tool.pyo")))


if __name__ == "__main__":
    unittest.main()
