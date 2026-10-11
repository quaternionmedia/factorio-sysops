# Local POC Verification

This is a local, copy-only verification lane. It validates the mod tree without
starting Factorio and leaves semantic acceptance pending until a person performs
the manual benchmark.

## Static gate

From the repository root:

```powershell
python -B .\sysadmin-poc\scripts\verify_mod.py
python -B -m unittest discover -s tests -p 'test_verify_mod.py' -v
```

`verify_mod.py` uses only the Python standard library. It validates the required
`info.json` fields and every literal mod-local runtime asset reference in the
current Lua forms: direct `__sysadmin-poc__/...` references and the shared
`sprite_path .. "file.png"` form. Built-in Factorio assets and dynamically
constructed paths remain a runtime concern.

## Disposable installer staging and hash check

Do not call `install-mod.py install` without `--dest`: that form may replace
the normal mod directory. This bounded invocation exercises the real installer
only in a newly created temporary directory. The preflight rejects an existing
destination, so the installer's replacement branch cannot run:

```powershell
$pocRoot = Join-Path $env:TEMP ("qm-factorio-sysops-poc-" + [guid]::NewGuid())
$mods = Join-Path $pocRoot 'mods'
New-Item -ItemType Directory -Path $pocRoot | Out-Null
New-Item -ItemType Directory -Path $mods | Out-Null
$stagedMod = Join-Path $mods 'sysadmin-poc'
if (Test-Path -LiteralPath $stagedMod) { throw "POC destination already exists: $stagedMod" }
python -B .\sysadmin-poc\scripts\install-mod.py install --dest $mods
python -B .\sysadmin-poc\scripts\verify_mod.py --installed-mod $stagedMod
```

The comparison is read-only. Its SHA-256 manifest uses the installer's
`*.py`/`__pycache__` exclusion policy. The only writes above are a newly named
temporary copy; it does not change an installed mod or a save.

## Human-owned manual benchmark

The current Factorio log identifies this local Factorio 2.0.77 binary and
write-data root:

```powershell
$factorio = 'E:\SteamLibrary\steamapps\common\Factorio\bin\x64\Factorio.exe'
$factorioData = Join-Path $env:APPDATA 'Factorio'
Test-Path -LiteralPath $factorio
```

Do not start Factorio from automation. A human may start that binary with the
staged mod directory (`--mod-directory $mods` is supported by this installed
Factorio distribution), enable `sysadmin-poc`, and use a new or explicitly
copied test save. Do not load, replace, or autosave over an existing save,
including `sysadmin_testing.zip` or an autosave in `$factorioData\saves`.

Build two independent chains in the disposable save. Chain A is a normal
assembler â†’ sensor â†’ cable â†’ server path. Chain B uses the same path but
connects a constant combinator to its data sensor with
`signal-it-control = 1`. Let technical debt accumulate while the in-game
server entity stops draining packets, then reconnect it. Record that Chain A's effective speed
falls and recovers, while Chain B retains its coverage bonus; check the
circuit bridge's technical-debt signal and `/sysadmin-stats` for errors. With
50 or more sensors, record `/time-usage` against the stated 60-tick (<1 ms)
and 10-tick (<0.5 ms) targets. Record the actual Factorio build, save-copy
name, mod manifest hash, and observed timings.

`HANDOFF-MULTI-REPO.md` is historical context, not a procedure for this POC:
its installation instruction may replace an installed mod and must not be
run. **Semantic acceptance remains Pending until this bounded manual run is
recorded.** A static pass verifies packaging and assets, not game behavior or
performance.

## Composition boundaries

- Multiplayer membership stays with
  [factorio-server](https://github.com/quaternionmedia/factorio-server). Its
  identity-enrollment POC renders Factorio's native whitelist; this mod neither
  owns a whitelist nor changes server authorization.
- DataFactorio remains an optional file seam. The intended integration writes
  a JSON snapshot beneath `script-output/datafactorio/`, then DataFactorio
  imports it; it is not an RCON or source dependency. See
  [DATAFACTORIO-INTEGRATION.md](DATAFACTORIO-INTEGRATION.md). This POC does not
  implement that export or alter DataFactorio.
