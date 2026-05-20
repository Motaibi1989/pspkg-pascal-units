# pspkg Pascal Units - Project Files

This document tracks the Pascal units and support files in the `pspkg-pascal-units` repository.

## Repository

```text
Motaibi1989/pspkg-pascal-units
```

## Current Files

| File | Status | Purpose |
|---|---:|---|
| `pspkg.pas` | Existing | Main demo/test program |
| `uCore.pas` | Existing | Shared command execution and utility functions |
| `uLOGM.pas` | Existing | Basic console logging unit |
| `uLogger.pas` | Added | Advanced logger with log levels, file logging, rotation, quiet mode, and JSON mode |
| `uUtils.pas` | Added | Shared helpers such as JSON escaping, root check, home directory, file read, and string matching |
| `uPlatform.pas` | Added | OS/platform detection and default shell helpers |
| `uOpen.pas` | Added | Cross-platform open path / open URL helper |
| `uSYSM.pas` | Existing | System information unit |
| `uNETM.pas` | Existing | Network, HTTP, ping, and adapter functions |
| `uConfig.pas` | Added | Shared application constants and project settings |
| `README.md` | Existing | Main repository documentation |
| `PROJECT_FILES.md` | Updated | Project file inventory and roadmap |
| `.github/workflows/build.yml` | Existing | GitHub Actions Linux build workflow |

## Planned Additional Units

| File | Purpose |
|---|---|
| `uSessionInfo.pas` | User sessions, login state, and terminal/RDP session details |
| `uServerStatus.pas` | Server health summary and status checks |
| `uSystemInfoEx.pas` | Extended system, kernel, hardware, BIOS, PCI/USB, and OS details |
| `uSystemInfo.pas` | Standard system information wrapper |
| `uVmManager.pas` | VM management actions such as start, stop, pause, resume, reset, save, and headless start |
| `uMountManager.pas` | Disk mount, unmount, filesystem, and mount-point checks |
| `uServiceManager.pas` | Service actions such as start, stop, restart, reload, enable, disable, and status |
| `uPackageManager.pas` | Package manager operations for install, remove, update, upgrade, and search |

## Build Command

```bash
fpc pspkg.pas
```

## Linux Dependencies

```bash
sudo apt update
sudo apt install -y fpc util-linux pciutils usbutils dmidecode iproute2 procps systemd
```

## Development Notes

- Target compiler: Free Pascal Compiler `fpc`.
- Target mode: `{$mode objfpc}{$H+}`.
- Avoid `TArray<T>` syntax for FPC compatibility.
- Avoid object ownership inside records unless lifecycle is clearly handled.
- Prefer indexed loops over `for..in` for dynamic arrays in `objfpc` mode.
- Use `StdErr` for errors.
- Keep Linux and Windows code separated with compiler directives.
- Use `uLogger.pas` for advanced logging and keep `uLOGM.pas` only if backward compatibility is needed.

## Recent Updates

- Added `uLogger.pas`.
- Added `uUtils.pas`.
- Added `uPlatform.pas`.
- Added `uOpen.pas`.
- Added `uConfig.pas`.

## Next Step

Update `pspkg.pas` to use the new units and add the remaining manager modules one by one.
