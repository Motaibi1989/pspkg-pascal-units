unit uSYSM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, Process, uCore;

type
  TSystemInfo = record
    HostName        : string;
    UserName        : string;
    OSName          : string;
    OSVersion       : string;
    CPUArchitecture : string;
    CPUCount        : Integer;
    TotalRAM        : Int64;
    FreeRAM         : Int64;
    UptimeSeconds   : Int64;
    LastBootTime    : TDateTime;
    DiskTotal       : Int64;
    DiskFree        : Int64;
    IPAddress       : string;
    MACAddress      : string;
    DefaultGateway  : string;
  end;

function GetSystemInfo: TSystemInfo;
function GetUptimeSeconds: Int64;
function GetCurrentUserName: string;
function GetCurrentHostName: string;
function GetIPAddress: string;
function GetMACAddress: string;
function GetDefaultGW: string;
function GetCPUInfo: string;
function GetRAMTotal: Int64;
function GetRAMFree: Int64;
function GetDiskTotal(const APath: string = '/'): Int64;
function GetDiskFree(const APath: string = '/'): Int64;
function GetOSInfo: string;
function ExecuteAndCapture(const ACmd: string): string;

implementation

function ExecuteAndCapture(const ACmd: string): string;
var
  R: TExecResult;
begin
  R := RunShell(ACmd);
  Result := Trim(R.Output);
end;

function GetCurrentHostName: string;
begin
  Result := Trim(ExecuteAndCapture('hostname'));
end;

function GetCurrentUserName: string;
begin
  Result := Trim(ExecuteAndCapture('whoami'));
end;

function GetOSInfo: string;
begin
  {$IFDEF WINDOWS}
  Result := Trim(ExecuteAndCapture('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"'));
  if Result = '' then Result := 'Windows';
  {$ELSE}
  if FileExists('/etc/os-release') then
    Result := Trim(ExecuteAndCapture('grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d ''"'''))
  else
    Result := Trim(ExecuteAndCapture('uname -s'));
  {$ENDIF}
end;

function GetUptimeSeconds: Int64;
{$IFDEF UNIX}
var
  F: TextFile;
  S: string;
  Parts: TStringArray;
{$ENDIF}
begin
  Result := 0;
  {$IFDEF UNIX}
  if FileExists('/proc/uptime') then
  begin
    AssignFile(F, '/proc/uptime');
    Reset(F);
    try
      ReadLn(F, S);
      Parts := S.Split([' ']);
      if Length(Parts) > 0 then
        Result := Trunc(StrToFloatDef(Parts[0], 0));
    finally
      CloseFile(F);
    end;
  end;
  {$ENDIF}

  {$IFDEF WINDOWS}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "[int64]((Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime).TotalSeconds"')), 0);
  {$ENDIF}
end;

function GetCPUInfo: string;
begin
  {$IFDEF WINDOWS}
  Result := Trim(ExecuteAndCapture('powershell -NoProfile -Command "(Get-CimInstance Win32_Processor | Select-Object -First 1).Name"'));
  {$ELSE}
  Result := Trim(ExecuteAndCapture('grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2'));
  if Result = '' then
    Result := Trim(ExecuteAndCapture('uname -m'));
  {$ENDIF}
end;

function GetRAMTotal: Int64;
begin
  Result := 0;
  {$IFDEF WINDOWS}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"')), 0);
  {$ELSE}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'grep MemTotal /proc/meminfo | awk ''{print $2}''')), 0) * 1024;
  {$ENDIF}
end;

function GetRAMFree: Int64;
begin
  Result := 0;
  {$IFDEF WINDOWS}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1024"')), 0);
  {$ELSE}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'grep MemAvailable /proc/meminfo | awk ''{print $2}''')), 0) * 1024;
  {$ENDIF}
end;

function GetDiskTotal(const APath: string = '/'): Int64;
begin
  {$IFDEF WINDOWS}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-CimInstance Win32_LogicalDisk -Filter ''DeviceID=''''C:'''' '').Size"')), 0);
  {$ELSE}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'df --output=size -B1 ' + APath + ' | tail -1')), 0);
  {$ENDIF}
end;

function GetDiskFree(const APath: string = '/'): Int64;
begin
  {$IFDEF WINDOWS}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-CimInstance Win32_LogicalDisk -Filter ''DeviceID=''''C:'''' '').FreeSpace"')), 0);
  {$ELSE}
  Result := StrToInt64Def(Trim(ExecuteAndCapture(
    'df --output=avail -B1 ' + APath + ' | tail -1')), 0);
  {$ENDIF}
end;

function GetIPAddress: string;
begin
  {$IFDEF WINDOWS}
  Result := Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike ''127.*''} | Select-Object -First 1).IPAddress"'));
  {$ELSE}
  Result := Trim(ExecuteAndCapture('hostname -I | awk ''{print $1}'''));
  {$ENDIF}
end;

function GetMACAddress: string;
begin
  {$IFDEF WINDOWS}
  Result := Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-NetAdapter | Where-Object {$_.Status -eq ''Up''} | Select-Object -First 1).MacAddress"'));
  {$ELSE}
  Result := Trim(ExecuteAndCapture(
    'cat /sys/class/net/$(ip route | awk ''/default/{print $5}'' | head -1)/address 2>/dev/null'));
  {$ENDIF}
end;

function GetDefaultGW: string;
begin
  {$IFDEF WINDOWS}
  Result := Trim(ExecuteAndCapture(
    'powershell -NoProfile -Command "(Get-NetRoute -DestinationPrefix ''0.0.0.0/0'' | Sort-Object RouteMetric | Select-Object -First 1).NextHop"'));
  {$ELSE}
  Result := Trim(ExecuteAndCapture('ip route | awk ''/default/{print $3}'' | head -1'));
  {$ENDIF}
end;

function GetSystemInfo: TSystemInfo;
var
  UptimeSecs: Int64;
begin
  UptimeSecs := GetUptimeSeconds;

  Result.HostName        := GetCurrentHostName;
  Result.UserName        := GetCurrentUserName;
  Result.OSName          := GetOSInfo;
  {$IFDEF WINDOWS}
  Result.OSVersion       := Trim(ExecuteAndCapture('ver'));
  Result.CPUCount        := StrToIntDef(Trim(ExecuteAndCapture(
                            'powershell -NoProfile -Command "$env:NUMBER_OF_PROCESSORS"')), 1);
  {$ELSE}
  Result.OSVersion       := Trim(ExecuteAndCapture('uname -r'));
  Result.CPUCount        := StrToIntDef(Trim(ExecuteAndCapture('nproc')), 1);
  {$ENDIF}
  Result.CPUArchitecture := GetCPUInfo;
  Result.TotalRAM        := GetRAMTotal;
  Result.FreeRAM         := GetRAMFree;
  Result.UptimeSeconds   := UptimeSecs;
  Result.LastBootTime    := Now - (UptimeSecs / 86400);
  Result.DiskTotal       := GetDiskTotal('/');
  Result.DiskFree        := GetDiskFree('/');
  Result.IPAddress       := GetIPAddress;
  Result.MACAddress      := GetMACAddress;
  Result.DefaultGateway  := GetDefaultGW;
end;

end.
