unit uPlatform;

{$mode objfpc}{$H+}

interface

type
  TOSType = (osUnknown, osLinux, osWindows, osMacOS, osFreeBSD);

function GetOSType: TOSType;
function GetOSTypeName: string;
function IsWindows: Boolean;
function IsUnixLike: Boolean;
function DefaultShell: string;
function DefaultShellFlag: string;

implementation

function GetOSType: TOSType;
begin
  {$IFDEF WINDOWS}
  Result := osWindows;
  {$ELSEIF DEFINED(DARWIN)}
  Result := osMacOS;
  {$ELSEIF DEFINED(FREEBSD)}
  Result := osFreeBSD;
  {$ELSEIF DEFINED(LINUX)}
  Result := osLinux;
  {$ELSE}
  Result := osUnknown;
  {$ENDIF}
end;

function GetOSTypeName: string;
begin
  case GetOSType of
    osLinux:   Result := 'Linux';
    osWindows: Result := 'Windows';
    osMacOS:   Result := 'macOS';
    osFreeBSD: Result := 'FreeBSD';
  else
    Result := 'Unknown';
  end;
end;

function IsWindows: Boolean;
begin
  Result := GetOSType = osWindows;
end;

function IsUnixLike: Boolean;
begin
  Result := GetOSType in [osLinux, osMacOS, osFreeBSD];
end;

function DefaultShell: string;
begin
  if IsWindows then
    Result := 'cmd.exe'
  else
    Result := '/bin/sh';
end;

function DefaultShellFlag: string;
begin
  if IsWindows then
    Result := '/C'
  else
    Result := '-c';
end;

end.
