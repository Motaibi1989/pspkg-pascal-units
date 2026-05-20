unit uLOGM;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TLogLevel = (llDebug, llInfo, llWarn, llError);

  TLog = class
  public
    procedure Debug(const ASection, AMsg: string);
    procedure Info(const ASection, AMsg: string);
    procedure Warn(const ASection, AMsg: string);
    procedure Error(const ASection, AMsg: string);
    procedure ExceptionLog(E: Exception; const ASection: string);
  end;

implementation

procedure WriteLog(ALevel: TLogLevel; const ASection, AMsg: string);
const
  LevelText: array[TLogLevel] of string =
    ('DEBUG', 'INFO ', 'WARN ', 'ERROR');
begin
  if ALevel = llError then
    WriteLn(StdErr, '[', LevelText[ALevel], '] [', ASection, '] ', AMsg)
  else
    WriteLn('[', LevelText[ALevel], '] [', ASection, '] ', AMsg);
end;

procedure TLog.Debug(const ASection, AMsg: string);
begin
  WriteLog(llDebug, ASection, AMsg);
end;

procedure TLog.Info(const ASection, AMsg: string);
begin
  WriteLog(llInfo, ASection, AMsg);
end;

procedure TLog.Warn(const ASection, AMsg: string);
begin
  WriteLog(llWarn, ASection, AMsg);
end;

procedure TLog.Error(const ASection, AMsg: string);
begin
  WriteLog(llError, ASection, AMsg);
end;

procedure TLog.ExceptionLog(E: Exception; const ASection: string);
begin
  WriteLog(llError, ASection, E.ClassName + ': ' + E.Message);
end;

end.
