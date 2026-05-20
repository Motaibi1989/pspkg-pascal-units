// ─────────────────────────────────────────────────────────────────────────────
// uPackageManager.pas
// ─────────────────────────────────────────────────────────────────────────────
unit uPackageManager;

{$mode objfpc}{$H+}

interface

function PackageInstall(const PackageName: string): Boolean;
function PackageRemove(const PackageName: string): Boolean;
function PackageUpdate: Boolean;
function PackageUpgrade: Boolean;
function PackageSearch(const Query: string): string;

implementation

uses
  SysUtils, uCore;

type
  TPkgTool = (ptNone, ptApt, ptDnf, ptYum, ptPacman, ptBrew, ptChoco);

function DetectTool(out Exe: string): TPkgTool;
begin
  Exe := FindExecutable('apt-get'); if Exe <> '' then Exit(ptApt);
  Exe := FindExecutable('dnf');     if Exe <> '' then Exit(ptDnf);
  Exe := FindExecutable('yum');     if Exe <> '' then Exit(ptYum);
  Exe := FindExecutable('pacman');  if Exe <> '' then Exit(ptPacman);
  Exe := FindExecutable('brew');    if Exe <> '' then Exit(ptBrew);
  Exe := FindExecutable('choco');   if Exe <> '' then Exit(ptChoco);
  Result := ptNone;
end;

function RunPkg(const Args: array of string; Timeout: Integer = 120000): Boolean;
var
  Exe: string;
  R: TCommandResult;
begin
  if DetectTool(Exe) = ptNone then Exit(False);
  R := RunProcess(Exe, Args, Timeout);
  Result := R.Success;
end;

function CapPkg(const Args: array of string; Timeout: Integer = 120000): string;
var
  Exe: string;
  R: TCommandResult;
begin
  if DetectTool(Exe) = ptNone then Exit('Package manager not found');
  R := RunProcess(Exe, Args, Timeout);
  Result := Trim(R.Output + LineEnding + R.ErrorText);
end;

function PackageInstall(const PackageName: string): Boolean;
var Exe: string; T: TPkgTool;
begin
  T := DetectTool(Exe);
  case T of
    ptApt:    Result := RunPkg(['install','-y',PackageName]);
    ptDnf:    Result := RunPkg(['install','-y',PackageName]);
    ptYum:    Result := RunPkg(['install','-y',PackageName]);
    ptPacman: Result := RunPkg(['-S','--noconfirm',PackageName]);
    ptBrew:   Result := RunPkg(['install',PackageName]);
    ptChoco:  Result := RunPkg(['install',PackageName,'-y']);
  else
    Result := False;
  end;
end;

function PackageRemove(const PackageName: string): Boolean;
var Exe: string; T: TPkgTool;
begin
  T := DetectTool(Exe);
  case T of
    ptApt:    Result := RunPkg(['remove','-y',PackageName]);
    ptDnf:    Result := RunPkg(['remove','-y',PackageName]);
    ptYum:    Result := RunPkg(['remove','-y',PackageName]);
    ptPacman: Result := RunPkg(['-R','--noconfirm',PackageName]);
    ptBrew:   Result := RunPkg(['uninstall',PackageName]);
    ptChoco:  Result := RunPkg(['uninstall',PackageName,'-y']);
  else
    Result := False;
  end;
end;

function PackageUpdate: Boolean;
var Exe: string; T: TPkgTool;
begin
  T := DetectTool(Exe);
  case T of
    ptApt:    Result := RunPkg(['update']);
    ptDnf:    Result := RunPkg(['check-update']);
    ptYum:    Result := RunPkg(['check-update']);
    ptPacman: Result := RunPkg(['-Sy']);
    ptBrew:   Result := RunPkg(['update']);
    ptChoco:  Result := RunPkg(['upgrade','chocolatey','-y']);
  else
    Result := False;
  end;
end;

function PackageUpgrade: Boolean;
var Exe: string; T: TPkgTool;
begin
  T := DetectTool(Exe);
  case T of
    ptApt:    Result := RunPkg(['upgrade','-y']);
    ptDnf:    Result := RunPkg(['upgrade','-y']);
    ptYum:    Result := RunPkg(['update','-y']);
    ptPacman: Result := RunPkg(['-Syu','--noconfirm']);
    ptBrew:   Result := RunPkg(['upgrade']);
    ptChoco:  Result := RunPkg(['upgrade','all','-y']);
  else
    Result := False;
  end;
end;

function PackageSearch(const Query: string): string;
var Exe: string; T: TPkgTool;
begin
  T := DetectTool(Exe);
  case T of
    ptApt:    Result := CapPkg(['search',Query]);
    ptDnf:    Result := CapPkg(['search',Query]);
    ptYum:    Result := CapPkg(['search',Query]);
    ptPacman: Result := CapPkg(['-Ss',Query]);
    ptBrew:   Result := CapPkg(['search',Query]);
    ptChoco:  Result := CapPkg(['search',Query]);
  else
    Result := 'Package manager not found';
  end;
end;

end.
