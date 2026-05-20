// ─────────────────────────────────────────────────────────────────────────────
// uSystemInfo.pas
// ─────────────────────────────────────────────────────────────────────────────
unit uSystemInfo;

{$mode objfpc}{$H+}

interface

type
  TSystemInfoRec = record
    HostName      : string;
    OSVersion     : string;
    KernelVersion : string;
    CPUInfo       : string;
    MemoryInfo    : string;
    DiskInfo      : string;
    NetworkInfo   : string;
  end;

function GetSystemInfo: TSystemInfoRec;

implementation

uses
  SysUtils, uCore;

function Cap(const Exe: string; const Args: array of string; const Fallback: string = 'N/A'): string;
var
  P: string;
  R: TCommandResult;
begin
  P := FindExecutable(Exe);
  if P = '' then Exit(Fallback);
  R := RunProcess(P, Args, 15000);
  if R.Success then Result := Trim(R.Output) else Result := Fallback;
end;

function GetSystemInfo: TSystemInfoRec;
begin
{$IFDEF WINDOWS}
  Result.HostName      := Cap('hostname', []);
  Result.OSVersion     := Cap('cmd.exe', ['/C','ver']);
  Result.KernelVersion := Result.OSVersion;
  Result.CPUInfo       := Cap('powershell.exe', ['-NoProfile','-Command','(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name)']);
  Result.MemoryInfo    := Cap('powershell.exe', ['-NoProfile','-Command','Get-CimInstance Win32_OperatingSystem | Select TotalVisibleMemorySize,FreePhysicalMemory | Format-List | Out-String']);
  Result.DiskInfo      := Cap('powershell.exe', ['-NoProfile','-Command','Get-CimInstance Win32_LogicalDisk | Select DeviceID,Size,FreeSpace | Format-Table -Auto | Out-String']);
  Result.NetworkInfo   := Cap('powershell.exe', ['-NoProfile','-Command','Get-NetIPConfiguration | Format-List | Out-String']);
{$ELSE}
  Result.HostName      := Cap('hostname', []);
  Result.OSVersion     := Cap('sh', ['-c','cat /etc/os-release 2>/dev/null || uname -a']);
  Result.KernelVersion := Cap('uname', ['-r']);
  Result.CPUInfo       := Cap('sh', ['-c','lscpu 2>/dev/null || cat /proc/cpuinfo 2>/dev/null | head -30']);
  Result.MemoryInfo    := Cap('sh', ['-c','free -h 2>/dev/null || cat /proc/meminfo 2>/dev/null | head -10']);
  Result.DiskInfo      := Cap('df', ['-h']);
  Result.NetworkInfo   := Cap('sh', ['-c','ip addr 2>/dev/null || ifconfig 2>/dev/null']);
{$ENDIF}
end;

end.
