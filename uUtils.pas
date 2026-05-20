unit uUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

function EscapeJSON(const S: string): string;
function IsRoot: Boolean;
function GetUserHomeDir: string;
function FileReadAll(const AFileName: string): string;
function RightTrim(const S: string): string;           // renamed to avoid SysUtils clash
function MatchesAny(const S: string; const Candidates: array of string): Boolean;

implementation

function EscapeJSON(const S: string): string;
var
  C: Char;
begin
  Result := '';
  for C in S do
    case C of
      '"':  Result := Result + '\"';
      '\':  Result := Result + '\\';
      #10:  Result := Result + '\n';
      #13:  Result := Result + '\r';
      #9:   Result := Result + '\t';
      #8:   Result := Result + '\b';
      #12:  Result := Result + '\f';
    else
      if Ord(C) < 32 then
        Result := Result + '\u' + IntToHex(Ord(C), 4)
      else
        Result := Result + C;
    end;
end;

function IsRoot: Boolean;
begin
  {$IFDEF UNIX}
  Result := fpGetUID = 0;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function GetUserHomeDir: string;
begin
  Result := GetEnvironmentVariable('HOME');
  if Result = '' then
    Result := GetEnvironmentVariable('USERPROFILE');
  if Result = '' then
    Result := GetCurrentDir;
end;

function FileReadAll(const AFileName: string): string;
var
  F: TFileStream;
  Len: Int64;
begin
  Result := '';
  if not FileExists(AFileName) then Exit;
  F := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Len := F.Size;
    if Len = 0 then Exit;
    SetLength(Result, Len);
    F.ReadBuffer(Pointer(Result)^, Len);
  finally
    F.Free;
  end;
end;

function RightTrim(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] in [#1..#32]) do Dec(I);
  Result := Copy(S, 1, I);
end;

function MatchesAny(const S: string; const Candidates: array of string): Boolean;
var
  Lower, C: string;
  I: Integer;
begin
  Lower := LowerCase(S);
  for I := Low(Candidates) to High(Candidates) do
  begin
    C := LowerCase(Candidates[I]);
    if Lower = C then Exit(True);
  end;
  Result := False;
end;

end.
