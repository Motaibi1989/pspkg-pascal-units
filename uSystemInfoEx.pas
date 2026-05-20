// ─────────────────────────────────────────────────────────────────────────────
// uSystemInfoEx.pas
// ─────────────────────────────────────────────────────────────────────────────
unit uSystemInfoEx;

{$mode objfpc}{$H+}

interface

function GetSystemSummaryText: string;

implementation

uses
  SysUtils, uSystemInfo;

function FirstLine(const S: string): string;
var
  P: Integer;
begin
  P := Pos(LineEnding, S);
  if P > 0 then Result := Copy(S, 1, P - 1)
  else          Result := S;
end;

function GetSystemSummaryText: string;
var
  SI: TSystemInfoRec;
begin
  SI := GetSystemInfo;
  Result :=
    'Host Name      : ' + SI.HostName + LineEnding +
    'OS Version     : ' + FirstLine(SI.OSVersion) + LineEnding +
    'Kernel Version : ' + SI.KernelVersion + LineEnding +
    'CPU Info       : ' + FirstLine(SI.CPUInfo) + LineEnding +
    'Memory Info    : ' + FirstLine(SI.MemoryInfo) + LineEnding +
    'Disk Info      : ' + FirstLine(SI.DiskInfo) + LineEnding +
    'Network Info   : ' + FirstLine(SI.NetworkInfo);
end;

end.
