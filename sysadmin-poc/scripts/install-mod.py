#!/usr/bin/env python3
"""
Locate a Factorio installation and install this mod into its mods folder.

Mirrors datafactorio's `locate` / `install-mod` commands (see
~/repos/qm/datafactorio/src/datafactorio/cli.py) so both sibling projects are
deployed the same way, without pulling in a packaging/dependency toolchain
this mod otherwise has none of.

Usage:
    python scripts/install-mod.py locate
    python scripts/install-mod.py install [--dest PATH]
"""

import argparse
import os
import shutil
import sys
from pathlib import Path

MOD_SRC = Path(__file__).resolve().parent.parent  # scripts/ -> sysadmin-poc/
MOD_NAME = "sysadmin-poc"


def get_factorio_paths() -> dict:
    """Locate the Factorio user-data (mods) directory across platforms."""
    paths = {"data": None, "mods": None}

    if sys.platform == "win32":
        appdata = Path(os.environ.get("APPDATA", ""))
        factorio_data = appdata / "Factorio"
        if factorio_data.exists():
            paths["data"] = factorio_data
            paths["mods"] = factorio_data / "mods"
    elif sys.platform == "darwin":
        factorio_data = Path.home() / "Library" / "Application Support" / "factorio"
        if factorio_data.exists():
            paths["data"] = factorio_data
            paths["mods"] = factorio_data / "mods"
    else:
        factorio_data = Path.home() / ".factorio"
        if factorio_data.exists():
            paths["data"] = factorio_data
            paths["mods"] = factorio_data / "mods"

    return paths


def get_mods_folder() -> Path | None:
    mods = get_factorio_paths().get("mods")
    return mods if mods and mods.exists() else None


def cmd_locate(_args) -> None:
    paths = get_factorio_paths()
    if paths["data"]:
        print(f"Factorio data:  {paths['data']}")
        print(f"Mods folder:    {paths['mods']}")
    else:
        print("Could not auto-detect a Factorio user-data directory.", file=sys.stderr)
        raise SystemExit(1)


def cmd_install(args) -> None:
    dest_root = Path(args.dest) if args.dest else get_mods_folder()
    if dest_root is None:
        print("Error: could not auto-detect Factorio mods folder. Pass --dest.", file=sys.stderr)
        raise SystemExit(1)

    mod_dest = dest_root / MOD_NAME
    if mod_dest.exists():
        shutil.rmtree(mod_dest)
    # scripts/ holds both Lua (shipped, required at runtime) and Python dev
    # tooling (icon/sprite generation, this installer) -- exclude only the
    # latter, not the whole directory.
    shutil.copytree(MOD_SRC, mod_dest, ignore=shutil.ignore_patterns("*.py", "__pycache__"))
    print(f"Installed {MOD_NAME} to: {mod_dest}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("locate", help="Print detected Factorio paths").set_defaults(func=cmd_locate)

    install_parser = subparsers.add_parser("install", help="Copy the mod into the Factorio mods folder")
    install_parser.add_argument("--dest", help="Mods folder to install into (default: auto-detected)")
    install_parser.set_defaults(func=cmd_install)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
