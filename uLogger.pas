unit uLogger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs, uUtils;

type
  TLogLevel = (llDebug, llInfo, llWarn, llError);

procedure Log(Level: TLogLevel; const Msg: string);
procedure LogDebug(const Msg: string);
procedure LogInfo(const Msg: string);
procedure LogWarn(const Msg: string);
procedure LogError(const Msg: string);

procedure SetLogFile(const AFileName: string;
                     AMaxSizeBytes: Int64 = 10 * 1024 * 1024;
                     ARotateCount: Integer = 3);
procedure SetLogLevel(ALevel: TLogLevel);
procedure SetLogLevelFromString(const ALevel: string);
procedure SetQuietMode(AEnable: Boolean);
procedure SetJSONMode(AEnable: Boolean);

function LogLevelToString(ALevel: TLogLevel): string;
function StringToLogLevel(const ALevel: string;
                           ADefault: TLogLevel = llInfo): TLogLevel;

implementation

var
  GLogLock     : TCriticalSection = nil;
  GFileStream  : TFileStream      = nil;
  GFileName    : string           = '';
  GMaxSize     : Int64            = 10 * 1024 * 1024;
  GRotateCount : Integer          = 3;
  GThreshold   : TLogLevel        = llInfo;
  GQuiet       : Boolean          = False;
  GJsonMode    : Boolean          = False;

function LogLevelToString(ALevel: TLogLevel): string;
begin
  case ALevel of
    llDebug: Result := 'DEBUG';
    llInfo:  Result := 'INFO ';
    llWarn:  Result := 'WARN ';
    llError: Result := 'ERROR';
  else       Result := '?????';
  end;
end;

function StringToLogLevel(const ALevel: string; ADefault: TLogLevel): TLogLevel;
var
  S: string;
begin
  S := LowerCase(Trim(ALevel));
  if      S = 'debug'   then Result := llDebug
  else if S = 'info'    then Result := llInfo
  else if (S = 'warn') or (S = 'warning') then Result := llWarn
  else if S = 'error'   then Result := llError
  else                       Result := ADefault;
end;

procedure OpenFileAppend;
begin
  if GFileName = '' then Exit;
  if GFileStream <> nil then Exit;
  try
    if FileExists(GFileName) then
      GFileStream := TFileStream.Create(GFileName, fmOpenReadWrite or fmShareDenyNone)
    else
      GFileStream := TFileStream.Create(GFileName, fmCreate or fmShareDenyNone);
    GFileStream.Seek(0, soEnd);
  except
    GFileStream := nil;
    GFileName   := '';
  end;
end;

procedure RotateLog;
var
  I: Integer;
begin
  FreeAndNil(GFileStream);
  if GRotateCount < 1 then
  begin
    if FileExists(GFileName) then DeleteFile(GFileName);
    OpenFileAppend;
    Exit;
  end;

  if FileExists(GFileName + '.' + IntToStr(GRotateCount)) then
    DeleteFile(GFileName + '.' + IntToStr(GRotateCount));

  for I := GRotateCount - 1 downto 1 do
    if FileExists(GFileName + '.' + IntToStr(I)) then
      RenameFile(GFileName + '.' + IntToStr(I),
                 GFileName + '.' + IntToStr(I + 1));

  if FileExists(GFileName) then
    RenameFile(GFileName, GFileName + '.1');
  OpenFileAppend;
end;

procedure WriteLineToFile(const Line: string);
const
  LF: Byte = 10;
begin
  if GFileName = '' then Exit;
  OpenFileAppend;
  if GFileStream = nil then Exit;
  if GFileStream.Size >= GMaxSize then RotateLog;
  if GFileStream = nil then Exit;
  if Line <> '' then
    GFileStream.WriteBuffer(Pointer(Line)^, Length(Line));
  GFileStream.WriteBuffer(LF, 1);
end;

procedure Log(Level: TLogLevel; const Msg: string);
var
  Line: string;
begin
  if Level < GThreshold then Exit;

  if GJsonMode then
    Line := Format('{"time":"%s","level":"%s","message":"%s"}',
      [FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', Now),
       Trim(LogLevelToString(Level)),
       EscapeJSON(Msg)])
  else
    Line := Format('[%s] %s %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
       LogLevelToString(Level),
       Msg]);

  GLogLock.Acquire;
  try
    if not GQuiet then
    begin
      if Level >= llError then
        WriteLn(StdErr, Line)
      else
        WriteLn(Line);
    end;
    WriteLineToFile(Line);
  finally
    GLogLock.Release;
  end;
end;

procedure LogDebug(const Msg: string); begin Log(llDebug, Msg); end;
procedure LogInfo(const Msg: string);  begin Log(llInfo,  Msg); end;
procedure LogWarn(const Msg: string);  begin Log(llWarn,  Msg); end;
procedure LogError(const Msg: string); begin Log(llError, Msg); end;

procedure SetLogFile(const AFileName: string;
                     AMaxSizeBytes: Int64;
                     ARotateCount: Integer);
begin
  GLogLock.Acquire;
  try
    FreeAndNil(GFileStream);
    GFileName    := AFileName;
    GMaxSize     := AMaxSizeBytes;
    GRotateCount := ARotateCount;
  finally
    GLogLock.Release;
  end;
end;

procedure SetLogLevel(ALevel: TLogLevel);
begin
  GLogLock.Acquire;
  try
    GThreshold := ALevel;
  finally
    GLogLock.Release;
  end;
end;

procedure SetLogLevelFromString(const ALevel: string);
begin
  SetLogLevel(StringToLogLevel(ALevel, llInfo));
end;

procedure SetQuietMode(AEnable: Boolean);
begin
  GLogLock.Acquire;
  try
    GQuiet := AEnable;
  finally
    GLogLock.Release;
  end;
end;

procedure SetJSONMode(AEnable: Boolean);
begin
  GLogLock.Acquire;
  try
    GJsonMode := AEnable;
  finally
    GLogLock.Release;
  end;
end;

initialization
  GLogLock := TCriticalSection.Create;

finalization
  if GLogLock <> nil then
  begin
    GLogLock.Acquire;
    try
      FreeAndNil(GFileStream);
    finally
      GLogLock.Release;
      FreeAndNil(GLogLock);
    end;
  end;

end.
