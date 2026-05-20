unit uServerStatus;

{$mode objfpc}{$H+}

interface

function GetServerStatusText: string;

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
  R := RunProcess(P, Args, 10000);
  if R.Success then Result := Trim(R.Output) else Result := Fallback;
end;

function GetServerStatusText: string;
begin
  {$IFDEF WINDOWS}
  Result := 'Host: ' + Cap('hostname', []) + LineEnding +
            'User: ' + Cap('whoami', []) + LineEnding +
            'OS: Windows' + LineEnding +
            'Uptime: ' + Cap('powershell.exe', ['-NoProfile','-Command','[int64]((Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime).TotalSeconds']) + ' seconds';
  {$ELSE}
  Result := 'Host: ' + Cap('hostname', []) + LineEnding +
            'User: ' + Cap('whoami', []) + LineEnding +
            'Kernel: ' + Cap('uname', ['-r']) + LineEnding +
            'Uptime: ' + Cap('sh', ['-c','cut -d" " -f1 /proc/uptime 2>/dev/null']) + ' seconds' + LineEnding +
            'Load: ' + Cap('sh', ['-c','cat /proc/loadavg 2>/dev/null']);
  {$ENDIF}
end;

end.
