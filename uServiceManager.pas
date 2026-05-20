// ─────────────────────────────────────────────────────────────────────────────
// uServiceManager.pas
// ─────────────────────────────────────────────────────────────────────────────
unit uServiceManager;

{$mode objfpc}{$H+}

interface

function ServiceStart(const Name: string): Boolean;
function ServiceStop(const Name: string): Boolean;
function ServiceRestart(const Name: string): Boolean;
function ServiceReload(const Name: string): Boolean;
function ServiceEnable(const Name: string): Boolean;
function ServiceDisable(const Name: string): Boolean;
function ServiceStatus(const Name: string): string;

implementation

uses
  SysUtils, uCore;

function RunSvc(const Args: array of string): Boolean;
var
  Exe: string;
  R: TCommandResult;
begin
{$IFDEF WINDOWS}
  Exe := FindExecutable('sc.exe');
{$ELSE}
  Exe := FindExecutable('systemctl');
{$ENDIF}
  if Exe = '' then Exit(False);
  R := RunProcess(Exe, Args, 30000);
  Result := R.Success;
end;

function CapSvc(const Args: array of string): string;
var
  Exe: string;
  R: TCommandResult;
begin
{$IFDEF WINDOWS}
  Exe := FindExecutable('sc.exe');
{$ELSE}
  Exe := FindExecutable('systemctl');
{$ENDIF}
  if Exe = '' then Exit('Service tool not found');
  R := RunProcess(Exe, Args, 30000);
  Result := Trim(R.Output + LineEnding + R.ErrorText);
end;

function ServiceStart(const Name: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := RunSvc(['start', Name]);
{$ELSE}
  Result := RunSvc(['start', Name]);
{$ENDIF}
end;

function ServiceStop(const Name: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := RunSvc(['stop', Name]);
{$ELSE}
  Result := RunSvc(['stop', Name]);
{$ENDIF}
end;

function ServiceRestart(const Name: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := ServiceStop(Name) and ServiceStart(Name);
{$ELSE}
  Result := RunSvc(['restart', Name]);
{$ENDIF}
end;

function ServiceReload(const Name: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := False;
{$ELSE}
  Result := RunSvc(['reload', Name]);
{$ENDIF}
end;

function ServiceEnable(const Name: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := RunSvc(['config', Name, 'start=', 'auto']);
{$ELSE}
  Result := RunSvc(['enable', Name]);
{$ENDIF}
end;

function ServiceDisable(const Name: string): Boolean;
begin
{$IFDEF WINDOWS}
  Result := RunSvc(['config', Name, 'start=', 'disabled']);
{$ELSE}
  Result := RunSvc(['disable', Name]);
{$ENDIF}
end;

function ServiceStatus(const Name: string): string;
begin
{$IFDEF WINDOWS}
  Result := CapSvc(['query', Name]);
{$ELSE}
  Result := CapSvc(['status', Name, '--no-pager']);
{$ENDIF}
end;

end.
