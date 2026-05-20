# pspkg Pascal Units - Project Files

This document tracks all Pascal source files, documentation files, build files, duplicate functions, and the refactoring plan for the `pspkg-pascal-units` repository.

## Repository

```text
Motaibi1989/pspkg-pascal-units
```

## Current Project Tree

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
├─ uSessionInfo.pas
├─ uServerStatus.pas
├─ uSystemInfo.pas
├─ uSystemInfoEx.pas
├─ uVmManager.pas
├─ uMountManager.pas
├─ uServiceManager.pas
├─ uPackageManager.pas
├─ README.md
├─ PROJECT_FILES.md
└─ .github/workflows/build.yml
```

## Current Files

| File | Status | Purpose |
|---|---:|---|
| `pspkg.pas` | Active | Main demo/test program |
| `uCore.pas` | Active / Base | Shared foundation: command execution, file helpers, temp dir, datetime, admin/root check, sleep, basic log |
| `uLogger.pas` | Active | Advanced logger with log levels, file logging, rotation, quiet mode, and JSON mode |
| `uPlatform.pas` | Active | OS/platform detection and default shell helpers |
| `uOpen.pas` | Active | Cross-platform open path / open URL helper |
| `uConfig.pas` | Active | Shared application constants and project settings |
| `uNETM.pas` | Active | Network, HTTP, ping, adapters, and internet checks |
| `uSystemInfo.pas` | Active | Main standard system information unit |
| `uSystemInfoEx.pas` | Active | Extended system/kernel/hardware summary wrapper |
| `uSessionInfo.pas` | Active | User session, login state, machine name, and terminal/session details |
| `uServerStatus.pas` | Active | Server health/status summary |
| `uVmManager.pas` | Active | VirtualBox VM management actions |
| `uMountManager.pas` | Active | Mount, unmount, mount checks, and mount listing |
| `uServiceManager.pas` | Active | Service start/stop/restart/reload/enable/disable/status |
| `uPackageManager.pas` | Active | Package install/remove/update/upgrade/search |
| `uUtils.pas` | Refactor Candidate | Keep only real helpers such as `EscapeJSON`; remove duplicates/trivial wrappers |
| `uLOGM.pas` | Legacy Candidate | Basic old logger; keep temporarily only for backward compatibility |
| `uSYSM.pas` | Legacy Candidate | Older system information unit; replace later with `uSystemInfo.pas` |
| `README.md` | Documentation | Main repository documentation |
| `PROJECT_FILES.md` | Documentation | Project inventory, duplicate analysis, and refactoring plan |
| `.github/workflows/build.yml` | Build | GitHub Actions Linux build workflow |

## Duplicate Functions Review

| Task | Unit | Pascal Header | Recommendation |
|---|---|---|---|
| Timestamped console log | `uCore` | `procedure Log(const Msg: string);` | Keep `uCore.Log` |
| Timestamped console log | `uUtils` | `procedure LogMessage(const Msg: string);` | Remove |
| Sleep milliseconds | `uCore` | `procedure SleepMs(Milliseconds: Word);` | Keep `uCore.SleepMs` |
| Sleep milliseconds | `uUtils` | `procedure Delay(Milliseconds: Word);` | Remove |
| Split string by delimiter | `uCore` | `procedure SplitString(const Delimiter: Char; Input: string; const Strings: TStrings);` | Keep if caller needs `TStrings` output |
| Split string by delimiter | `uUtils` | `function Split(const Delimiter: Char; const S: string): TStringArray;` | Keep only if array return is required; otherwise remove |
| Get temp directory | `uCore` | `function GetTempDir: string;` | Keep and unify implementation |
| Get temp directory | `uUtils` | `function GetTempDir: string;` | Remove |
| Current datetime string | `uCore` | `function GetCurrentDateTimeStr: string;` | Keep |
| Current datetime string | `uUtils` | `function GetCurrentDateTime: string;` | Remove |

## Unique Unit Responsibilities

| Unit | Unique Functionality | Pascal Header |
|---|---|---|
| `uCore` | Run command with timeout and output capture | `function RunCommand(const exe: string; const args: array of string; out output: string; timeoutMs: Integer = 0): Boolean;` |
| `uCore` | Read whole file to string | `function FileToString(const filename: string): string;` |
| `uCore` | Write string to file | `function StringToFile(const filename, content: string): Boolean;` |
| `uCore` | Check admin/root privileges | `function IsRunningAsAdmin: Boolean;` |
| `uPlatform` | OS type detection | `function GetOSType: TOSType;` |
| `uPlatform` | Check if Windows | `function IsWindows: Boolean;` |
| `uPlatform` | Check if Unix-like | `function IsUnixLike: Boolean;` |
| `uPlatform` | Platform-aware command runner | `function RunCommandPlatform(const cmd: string; out output: string): Boolean;` |
| `uSystemInfo` | Standard system information | `function GetSystemInfo: TSystemInfoRec;` |
| `uSystemInfoEx` | Extended system summary text | `function GetSystemSummaryText: string;` |
| `uSYSM` | Full legacy system info record | `function GetSystemInfo: TSystemInfo;` |
| `uNETM` | HTTP GET request | `function HTTPGet(const url: string; out response: string): Boolean;` |
| `uNETM` | HTTP POST request | `function HTTPPost(const url, data: string; out response: string): Boolean;` |
| `uNETM` | Ping a host | `function PingHost(const host: string; timeoutMs: Integer = 2000): Boolean;` |
| `uNETM` | Get network adapters list | `function GetNetworkAdapters: TAdapterList;` |
| `uNETM` | Check internet connectivity | `function IsInternetAvailable: Boolean;` |
| `uLogger` | Create logger instance | `function CreateLogger(const filename: string; level: TLogLevel = llInfo): TLogger;` |
| `uLogger` | Log with level | `procedure LogMsg(const msg: string; level: TLogLevel = llInfo);` |
| `uLogger` | Set log rotation | `procedure SetRotation(maxSizeMB: Integer; maxBackupFiles: Integer);` |
| `uLogger` | Export logs as JSON | `function ExportAsJSON: string;` |
| `uConfig` | Load INI-style config | `function LoadConfig(const filename: string): TConfig;` |
| `uConfig` | Read string value | `function ReadString(const section, key, default: string): string;` |
| `uConfig` | Write string value | `procedure WriteString(const section, key, value: string);` |
| `uConfig` | Save config to file | `function SaveConfig: Boolean;` |
| `uOpen` | Open URL in default browser | `function OpenURL(const url: string): Boolean;` |
| `uOpen` | Open file with default app | `function OpenFile(const filename: string): Boolean;` |

## Refactoring Decision Table

| Area | Recommendation | Action |
|---|---|---|
| `uCore` | Keep as main shared foundation | Centralize command execution, file helpers, temp dir, datetime, admin/root, sleep |
| `uUtils` | Clean or remove | Remove duplicate wrappers; keep only real helpers like `EscapeJSON` |
| `uLogger` | Keep for advanced logging | Log levels, file logging, rotation, JSON mode |
| `uLOGM` | Mark as legacy | Keep temporarily for compatibility or remove later |
| `uPlatform` | Keep focused | OS detection and shell helpers only |
| `uOpen` | Keep focused | Open URL/file/path only |
| `uNETM` | Keep focused | HTTP, ping, adapters, internet check |
| `uSYSM` | Legacy / duplicate | Replace later with `uSystemInfo` |
| `uSystemInfo` | Keep as main system info unit | Standard system info API |
| `uSystemInfoEx` | Keep as extended summary | Hardware/kernel/OS summary |
| `pspkg.pas` | Update after cleanup | Use final units only |
| `README.md` | Update | Reflect final structure |
| `PROJECT_FILES.md` | Update | Mark legacy/active/planned units |

## Refactoring Priority

| Priority | Task |
|---:|---|
| 1 | Refactor `uCore` as base API |
| 2 | Clean/remove duplicate functions from `uUtils` |
| 3 | Update `uLogger` dependencies |
| 4 | Decide whether to remove or keep `uLOGM` as legacy |
| 5 | Decide whether to remove or keep `uSYSM` as legacy |
| 6 | Update `pspkg.pas` |
| 7 | Update `README.md` and `PROJECT_FILES.md` |
| 8 | Run/verify GitHub Actions build |

## Build Command

```bash
fpc pspkg.pas
```

## Run Commands

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
- Avoid `TArray<T>` syntax for FPC compatibility.
- Avoid object ownership inside records unless lifecycle is clearly handled.
- Prefer indexed loops over `for..in` for dynamic arrays in `objfpc` mode.
- Use `StdErr` for errors.
- Keep Linux and Windows code separated with compiler directives.
- Use `uLogger.pas` for advanced logging.
- Keep `uLOGM.pas` only if backward compatibility is needed.
- Keep `uSYSM.pas` only as legacy until all callers move to `uSystemInfo.pas`.
- Keep all units modular and reusable.

## Recent Updates

- Added duplicate function review table.
- Added unique responsibility table.
- Added refactoring decision table.
- Added refactoring priority list.
- Updated current project tree with all uploaded units.

## Next Step

Clean `uUtils.pas`, update `uCore.pas` as the base API, then update `pspkg.pas` to use the final unit structure.
