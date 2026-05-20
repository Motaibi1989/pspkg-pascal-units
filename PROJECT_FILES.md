# pspkg Pascal Units - Project Files

This document lists the planned Pascal units and their purpose for the `pspkg-pascal-units` repository.

## Repository

```text
Motaibi1989/pspkg-pascal-units
```

## Current Core Files

| File | Purpose |
|---|---|
| `pspkg.pas` | Main demo/test program |
| `uCore.pas` | Shared command execution and utility functions |
| `uLOGM.pas` | Console logging unit |
| `uSYSM.pas` | System information unit |
| `uNETM.pas` | Network, HTTP, ping, and adapter functions |
| `README.md` | Main repository documentation |
| `.github/workflows/build.yml` | GitHub Actions Linux build workflow |

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
| `uConfig.pas` | Shared configuration constants and project settings |

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

## Next Step

Add the missing units one by one and update `pspkg.pas` to test each module.
