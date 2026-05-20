unit uNETM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, openssl, opensslsockets, Process, uCore;

type
  THTTPResponse = record
    StatusCode   : Integer;
    Content      : string;
    HeaderText   : string;
    Success      : Boolean;
    ErrorMessage : string;
  end;

  TNetworkAdapterInfo = record
    AdapterName : string;
    MACAddress  : string;
    IPAddress   : string;
    SubnetMask  : string;
    Gateway     : string;
    DHCPEnabled : Boolean;
  end;

  TNetworkAdapterArray = array of TNetworkAdapterInfo;

function HTTPGet(const AURL: string; ATimeout: Integer = 10000): THTTPResponse;
function HTTPPost(const AURL: string; const AData: TStringList; ATimeout: Integer = 10000): THTTPResponse;
function IsInternetConnected: Boolean;
function GetNetworkAdapters: TNetworkAdapterArray;
function PingHost(const AHost: string; ATimeout: Integer = 1000): Boolean;

implementation

function HTTPGet(const AURL: string; ATimeout: Integer = 10000): THTTPResponse;
var
  Client  : TFPHTTPClient;
  Headers : TStringList;
begin
  Result.StatusCode   := 0;
  Result.Content      := '';
  Result.HeaderText   := '';
  Result.Success      := False;
  Result.ErrorMessage := '';

  Client  := TFPHTTPClient.Create(nil);
  Headers := TStringList.Create;
  try
    Client.AddHeader('User-Agent', 'pspkg/2.0 (FPC)');
    Client.Timeout := ATimeout;
    try
      Result.Content    := Client.Get(AURL);
      Result.StatusCode := Client.ResponseStatusCode;
      Headers.AddStrings(Client.ResponseHeaders);
      Result.HeaderText := Headers.Text;
      Result.Success    := (Result.StatusCode >= 200) and (Result.StatusCode < 300);
    except
      on E: Exception do
      begin
        Result.ErrorMessage := E.Message;
        Result.Success      := False;
      end;
    end;
  finally
    Headers.Free;
    Client.Free;
  end;
end;

function HTTPPost(const AURL: string; const AData: TStringList; ATimeout: Integer = 10000): THTTPResponse;
var
  Client  : TFPHTTPClient;
  Headers : TStringList;
begin
  Result.StatusCode   := 0;
  Result.Content      := '';
  Result.HeaderText   := '';
  Result.Success      := False;
  Result.ErrorMessage := '';

  Client  := TFPHTTPClient.Create(nil);
  Headers := TStringList.Create;
  try
    Client.AddHeader('User-Agent', 'pspkg/2.0 (FPC)');
    Client.AddHeader('Content-Type', 'application/x-www-form-urlencoded');
    Client.Timeout := ATimeout;
    try
      Result.Content    := Client.FormPost(AURL, AData);
      Result.StatusCode := Client.ResponseStatusCode;
      Headers.AddStrings(Client.ResponseHeaders);
      Result.HeaderText := Headers.Text;
      Result.Success    := (Result.StatusCode >= 200) and (Result.StatusCode < 300);
    except
      on E: Exception do
      begin
        Result.ErrorMessage := E.Message;
        Result.Success      := False;
      end;
    end;
  finally
    Headers.Free;
    Client.Free;
  end;
end;

function IsInternetConnected: Boolean;
var
  R: THTTPResponse;
begin
  R := HTTPGet('http://clients3.google.com/generate_204', 2000);
  Result := R.Success or (R.StatusCode = 204);
end;

function PingHost(const AHost: string; ATimeout: Integer = 1000): Boolean;
var
  P: TProcess;
begin
  P := TProcess.Create(nil);
  try
    P.Executable := 'ping';
    {$IFDEF WINDOWS}
    P.Parameters.Add('-n');
    P.Parameters.Add('1');
    P.Parameters.Add('-w');
    P.Parameters.Add(IntToStr(ATimeout));
    {$ELSE}
    P.Parameters.Add('-c');
    P.Parameters.Add('1');
    P.Parameters.Add('-W');
    P.Parameters.Add(IntToStr(ATimeout div 1000));
    {$ENDIF}
    P.Parameters.Add(AHost);
    P.Options := [poWaitOnExit, poNoConsole];
    P.Execute;
    Result := P.ExitStatus = 0;
  finally
    P.Free;
  end;
end;

function GetNetworkAdapters: TNetworkAdapterArray;
{$IFDEF UNIX}
var
  SL    : TStringList;
  I     : Integer;
  Iface : string;
  Count : Integer;

  function ReadSysFile(const APath: string): string;
  var
    F: TextFile;
  begin
    Result := '';
    if not FileExists(APath) then Exit;
    AssignFile(F, APath);
    Reset(F);
    try
      ReadLn(F, Result);
    finally
      CloseFile(F);
    end;
    Result := Trim(Result);
  end;

  function RunForIface(const ACmd: string): string;
  var
    R: TExecResult;
  begin
    R := RunShell(ACmd);
    Result := Trim(R.Output);
  end;

begin
  SetLength(Result, 0);
  SL := TStringList.Create;
  try
    SL.Text := RunForIface('ls /sys/class/net | grep -v lo');
    Count := 0;
    SetLength(Result, SL.Count);

    for I := 0 to SL.Count - 1 do
    begin
      Iface := Trim(SL[I]);
      if Iface = '' then Continue;

      Result[Count].AdapterName := Iface;
      Result[Count].MACAddress  := ReadSysFile('/sys/class/net/' + Iface + '/address');
      Result[Count].IPAddress   := RunForIface('ip -4 addr show ' + Iface + ' | grep inet | awk ''{print $2}'' | cut -d/ -f1');
      Result[Count].SubnetMask  := RunForIface('ip -4 addr show ' + Iface + ' | grep inet | awk ''{print $2}'' | cut -d/ -f2');
      Result[Count].Gateway     := RunForIface('ip route | grep default | grep ' + Iface + ' | awk ''{print $3}''');
      Result[Count].DHCPEnabled :=
        FileExists('/run/systemd/netif/leases') or
        (RunForIface('cat /etc/network/interfaces 2>/dev/null | grep -A5 ' + Iface + ' | grep dhcp') <> '');
      Inc(Count);
    end;

    SetLength(Result, Count);
  finally
    SL.Free;
  end;
end;
{$ELSE}
begin
  SetLength(Result, 0);
end;
{$ENDIF}

end.
