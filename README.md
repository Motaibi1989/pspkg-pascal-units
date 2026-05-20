# pspkg Pascal Units

Cross-platform Free Pascal toolkit for system information, logging, command execution, network checks, platform detection, and helper utilities.

## Repository

```text
Motaibi1989/pspkg-pascal-units
```

## Files

```text
pspkg-pascal-units/
├─ pspkg.pas
├─ uCore.pas
├─ uLOGM.pas
├─ uLogger.pas
├─ uUtils.pas
├─ uPlatform.pas
├─ uOpen.pas
├─ uConfig.pas
├─ uSYSM.pas
├─ uNETM.pas
├─ README.md
├─ PROJECT_FILES.md
└─ .github/workflows/build.yml
```

## Unit Summary

| File | Purpose |
|---|---|
| `pspkg.pas` | Main demo/test program |
| `uCore.pas` | Shared command execution and core helpers |
| `uLOGM.pas` | Basic console logging unit |
| `uLogger.pas` | Advanced logging with levels, file logging, quiet mode, and JSON mode |
| `uUtils.pas` | Shared helper functions |
| `uPlatform.pas` | OS/platform detection and shell helpers |
| `uOpen.pas` | Cross-platform open file/path/URL helper |
| `uConfig.pas` | Application constants and project settings |
| `uSYSM.pas` | System information functions |
| `uNETM.pas` | Network, HTTP, ping, and adapter functions |

## Build

```bash
fpc pspkg.pas
```

## Run

Linux/macOS:

```bash
./pspkg
```

Windows:

```bat
pspkg.exe
```

## Linux Dependencies

```bash
sudo apt update
sudo apt install -y fpc util-linux pciutils usbutils dmidecode iproute2 procps systemd
```

## Development Notes

- Target compiler: Free Pascal Compiler `fpc`.
- Target mode: `{$mode objfpc}{$H+}`.
- Keep Windows/Linux code separated using compiler directives.
- Avoid shell injection by passing executable and parameters safely where possible.
- Keep units modular and reusable.

## GitHub Actions

The repository includes a Linux build workflow:

```text
.github/workflows/build.yml
```

## GitHub Push Commands

```bash
git init
git add .
git commit -m "Initial Pascal units"
git branch -M main
git remote add origin https://github.com/Motaibi1989/pspkg-pascal-units.git
git push -u origin main
```
