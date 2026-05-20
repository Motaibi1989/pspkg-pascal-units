unit uCore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process;

type
  TExecResult = record
    Command: string;
    Output: string;
    ExitCode: Integer;
    Success: Boolean;
    ErrorMessage: string;
  end;

function RunCommand(const AExe: string; const AArgs: array of string): TExecResult;
function RunShell(const ACmd: string): TExecResult;
function BytesToGB(ABytes: Int64): Double;
function BoolToText(AValue: Boolean): string;

implementation

function RunCommand(const AExe: string; const AArgs: array of string): TExecResult;
var
  P: TProcess;
  SS: TStringStream;
  Buf: array[0..4095] of Byte;
  I, N: Integer;
begin
  Result.Command := AExe;
  Result.Output := '';
  Result.ExitCode := -1;
  Result.Success := False;
  Result.ErrorMessage := '';

  P := TProcess.Create(nil);
  SS := TStringStream.Create('');
  try
    P.Executable := AExe;

    for I := Low(AArgs) to High(AArgs) do
      P.Parameters.Add(AArgs[I]);

    P.Options := [poUsePipes, poStderrToOutput];
    P.Execute;

    repeat
      N := P.Output.Read(Buf, SizeOf(Buf));
      if N > 0 then
        SS.Write(Buf, N);
    until N = 0;

    P.WaitOnExit;

    Result.Output := Trim(SS.DataString);
    Result.ExitCode := P.ExitStatus;
    Result.Success := P.ExitStatus = 0;
  except
    on E: Exception do
      Result.ErrorMessage := E.Message;
  end;

  SS.Free;
  P.Free;
end;

function RunShell(const ACmd: string): TExecResult;
begin
  {$IFDEF WINDOWS}
  Result := RunCommand('cmd.exe', ['/C', ACmd]);
  {$ELSE}
  Result := RunCommand('/bin/bash', ['-lc', ACmd]);
  {$ENDIF}
  Result.Command := ACmd;
end;

function BytesToGB(ABytes: Int64): Double;
begin
  Result := ABytes / 1024 / 1024 / 1024;
end;

function BoolToText(AValue: Boolean): string;
begin
  if AValue then
    Result := 'Yes'
  else
    Result := 'No';
end;

end.
