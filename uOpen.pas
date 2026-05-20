unit uOpen;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Process;

function OpenPath(const APath: string): Boolean;
function OpenURL(const AURL: string): Boolean;

implementation

function RunDetached(const AExe: string; const AArg: string): Boolean;
var
  P: TProcess;
begin
  Result := False;
  P := TProcess.Create(nil);
  try
    P.Executable := AExe;
    if AArg <> '' then
      P.Parameters.Add(AArg);
    P.Options := [];
    try
      P.Execute;
      Result := True;
    except
      Result := False;
    end;
  finally
    P.Free;
  end;
end;

function OpenPath(const APath: string): Boolean;
begin
  {$IFDEF WINDOWS}
  Result := RunDetached('cmd.exe', '/C start "" "' + APath + '"');
  {$ELSEIF DEFINED(DARWIN)}
  Result := RunDetached('open', APath);
  {$ELSE}
  Result := RunDetached('xdg-open', APath);
  {$ENDIF}
end;

function OpenURL(const AURL: string): Boolean;
begin
  Result := OpenPath(AURL);
end;

end.
