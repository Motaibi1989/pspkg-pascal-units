// ─────────────────────────────────────────────────────────────────────────────
// uMountManager.pas
// ─────────────────────────────────────────────────────────────────────────────
unit uMountManager;

{$mode objfpc}{$H+}

interface

function MountDevice(const Device, MountPoint: string; const FsType: string = ''): Boolean;
function UnmountDevice(const MountPoint: string): Boolean;
function IsMounted(const MountPoint: string): Boolean;
function ListMounts: string;

implementation

uses
  SysUtils, uCore;

function RunCmd(const Exe: string; const Args: array of string; Timeout: Integer = 30000): Boolean;
var
  P: string;
  R: TCommandResult;
begin
  P := FindExecutable(Exe);
  if P = '' then Exit(False);
  R := RunProcess(P, Args, Timeout);
  Result := R.Success;
end;

function Capture(const Exe: string; const Args: array of string): string;
var
  P: string;
  R: TCommandResult;
begin
  P := FindExecutable(Exe);
  if P = '' then Exit('');
  R := RunProcess(P, Args, 30000);
  Result := Trim(R.Output);
end;

function MountDevice(const Device, MountPoint: string; const FsType: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := False;
{$ELSE}
  if FsType <> '' then
    Result := RunCmd('mount', ['-t', FsType, Device, MountPoint])
  else
    Result := RunCmd('mount', [Device, MountPoint]);
{$ENDIF}
end;

function UnmountDevice(const MountPoint: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := False;
{$ELSE}
  Result := RunCmd('umount', [MountPoint]);
{$ENDIF}
end;

function IsMounted(const MountPoint: string): Boolean;
var
  OutText: string;
begin
{$IFDEF WINDOWS}
  Result := DirectoryExists(MountPoint);
{$ELSE}
  OutText := Capture('findmnt', ['-n', MountPoint]);
  Result := OutText <> '';
{$ENDIF}
end;

function ListMounts: string;
begin
{$IFDEF WINDOWS}
  Result := Capture('powershell.exe', ['-NoProfile','-Command','Get-Volume | Format-Table -Auto | Out-String']);
{$ELSE}
  Result := Capture('findmnt', []);
  if Result = '' then Result := Capture('mount', []);
{$ENDIF}
end;

end.
