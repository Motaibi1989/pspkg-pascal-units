unit uSessionInfo;

{$mode objfpc}{$H+}

interface

type
  TSessionInfoRec = record
    UserName   : string;
    MachineName: string;
    SessionName: string;
    LoginTime  : string;
  end;

function GetSessionInfo: TSessionInfoRec;

implementation

uses
  SysUtils, uCore;

function Cap(const Exe: string; const Args: array of string;
             const Fallback: string = ''): string;
var
  P: string;
  R: TCommandResult;
begin
  P := FindExecutable(Exe);
  if P = '' then Exit(Fallback);
  R := RunProcess(P, Args, 10000);
  if R.Success then Result := Trim(R.Output) else Result := Fallback;
end;

function GetSessionInfo: TSessionInfoRec;
{$IFDEF WINDOWS}
var
  Exe: string;
  R  : TCommandResult;

  function PS(const Script: string; const Fallback: string = ''): string;
  begin
    if Exe = '' then Exit(Fallback);
    R := RunProcess(Exe, ['-NoProfile', '-NonInteractive', '-Command', Script], 10000);
    if R.Success then Result := Trim(R.Output) else Result := Fallback;
  end;
{$ENDIF}
begin
{$IFDEF WINDOWS}
  Exe := FindExecutable('pwsh');
  if Exe = '' then Exe := FindExecutable('powershell.exe');

  Result.UserName    := GetEnvironmentVariable('USERNAME');
  Result.MachineName := GetEnvironmentVariable('COMPUTERNAME');
  Result.SessionName := GetEnvironmentVariable('SESSIONNAME');
  // Retrieve logon time for the current session via CIM
  Result.LoginTime   := PS(
    '$sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value; ' +
    '(Get-CimInstance Win32_LogonSession | ' +
    ' Where-Object { (Get-CimAssociatedInstance $_ -ResultClassName Win32_UserAccount)' +
    '   .SID -eq $sid } | Sort-Object StartTime | Select-Object -Last 1).StartTime');
{$ELSE}
  Result.UserName    := Cap('whoami',   []);
  Result.MachineName := Cap('hostname', []);

  // Prefer $XDG_SESSION_TYPE, then $TERM as a rough indicator
  Result.SessionName := GetEnvironmentVariable('XDG_SESSION_TYPE');
  if Result.SessionName = '' then Result.SessionName := GetEnvironmentVariable('TERM');

  // who -m may be empty in non-interactive shells; fallback to last
  Result.LoginTime := Cap('sh', ['-c', 'who -m | awk ''{$1=$2=$3=""; print substr($0,4)}''']);
  if Result.LoginTime = '' then
    Result.LoginTime := Cap('sh', ['-c', 'last -n 1 "$USER" | head -1']);
{$ENDIF}
end;

end.
