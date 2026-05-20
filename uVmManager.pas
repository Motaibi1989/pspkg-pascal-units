// ─────────────────────────────────────────────────────────────────────────────
// uVmManager.pas
// ─────────────────────────────────────────────────────────────────────────────
unit uVmManager;

{$mode objfpc}{$H+}

interface

function VMStart(const VMName: string; Headless: Boolean = True): Boolean;
function VMStop(const VMName: string): Boolean;
function VMPause(const VMName: string): Boolean;
function VMResume(const VMName: string): Boolean;
function VMReset(const VMName: string): Boolean;
function VMSaveState(const VMName: string): Boolean;
function VMStatus(const VMName: string): string;

implementation

uses
  SysUtils, uCore;

function VBoxManagePath: string;
begin
  Result := FindExecutable('VBoxManage');
  {$IFDEF WINDOWS}
  if Result = '' then
    Result := 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe';
  {$ENDIF}
end;

function RunVBox(const Args: array of string; out Output: string): Boolean;
var
  Exe: string;
  R: TCommandResult;
begin
  Output := '';
  Exe := VBoxManagePath;
  if (Exe = '') or (not FileExists(Exe)) then Exit(False);
  R := RunProcess(Exe, Args, 60000);
  Output := Trim(R.Output + LineEnding + R.ErrorText);
  Result := R.Success;
end;

function VMStart(const VMName: string; Headless: Boolean): Boolean;
var O: string;
begin
  if Headless then
    Result := RunVBox(['startvm', VMName, '--type', 'headless'], O)
  else
    Result := RunVBox(['startvm', VMName], O);
end;

function VMStop(const VMName: string): Boolean;
var O: string;
begin
  Result := RunVBox(['controlvm', VMName, 'acpipowerbutton'], O);
end;

function VMPause(const VMName: string): Boolean;
var O: string;
begin
  Result := RunVBox(['controlvm', VMName, 'pause'], O);
end;

function VMResume(const VMName: string): Boolean;
var O: string;
begin
  Result := RunVBox(['controlvm', VMName, 'resume'], O);
end;

function VMReset(const VMName: string): Boolean;
var O: string;
begin
  Result := RunVBox(['controlvm', VMName, 'reset'], O);
end;

function VMSaveState(const VMName: string): Boolean;
var O: string;
begin
  Result := RunVBox(['controlvm', VMName, 'savestate'], O);
end;

function VMStatus(const VMName: string): string;
var O: string;
begin
  if RunVBox(['showvminfo', VMName, '--machinereadable'], O) then
    Result := O
  else
    Result := 'Unable to get VM status: ' + O;
end;

end.
