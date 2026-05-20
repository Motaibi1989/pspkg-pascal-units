program pspkg;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils,
  uCore,
  uLOGM,
  uSYSM,
  uNETM;

var
  Logger: TLog;

procedure ShowSystemInfo;
var
  SI: TSystemInfo;
begin
  Logger.Info('System', 'Gathering system information...');
  SI := GetSystemInfo;

  Logger.Info('System', 'Host     : ' + SI.HostName);
  Logger.Info('System', 'User     : ' + SI.UserName);
  Logger.Info('System', 'OS       : ' + SI.OSName);
  Logger.Info('System', 'Version  : ' + SI.OSVersion);
  Logger.Info('System', 'CPU      : ' + SI.CPUArchitecture);
  Logger.Info('System', 'CPU count: ' + IntToStr(SI.CPUCount));
  Logger.Info('System', Format('RAM total: %.2f GB', [BytesToGB(SI.TotalRAM)]));
  Logger.Info('System', Format('RAM free : %.2f GB', [BytesToGB(SI.FreeRAM)]));
  Logger.Info('System', Format('Disk total: %.2f GB', [BytesToGB(SI.DiskTotal)]));
  Logger.Info('System', Format('Disk free : %.2f GB', [BytesToGB(SI.DiskFree)]));
  Logger.Info('System', Format('Uptime   : %.1f hours', [SI.UptimeSeconds / 3600]));
  Logger.Info('System', 'IP       : ' + SI.IPAddress);
  Logger.Info('System', 'MAC      : ' + SI.MACAddress);
  Logger.Info('System', 'Gateway  : ' + SI.DefaultGateway);
end;

procedure TestNetwork;
var
  Adapters : TNetworkAdapterArray;
  HTTP     : THTTPResponse;
  I        : Integer;
begin
  Logger.Info('Network', 'Checking connectivity...');

  if IsInternetConnected then
  begin
    Logger.Info('Network', 'Internet: reachable');
    HTTP := HTTPGet('https://httpbin.org/get', 5000);
    if HTTP.Success then
      Logger.Info('Network', 'HTTP GET OK, status ' + IntToStr(HTTP.StatusCode))
    else
      Logger.Error('Network', 'HTTP GET failed: ' + HTTP.ErrorMessage);
  end
  else
    Logger.Warn('Network', 'Internet: not reachable');

  Logger.Info('Network', 'Listing adapters...');
  Adapters := GetNetworkAdapters;

  for I := 0 to High(Adapters) do
  begin
    Logger.Info('Network', 'Adapter : ' + Adapters[I].AdapterName);
    Logger.Info('Network', '  MAC   : ' + Adapters[I].MACAddress);
    Logger.Info('Network', '  IP    : ' + Adapters[I].IPAddress);
    Logger.Info('Network', '  CIDR  : ' + Adapters[I].SubnetMask);
    Logger.Info('Network', '  GW    : ' + Adapters[I].Gateway);
    Logger.Info('Network', '  DHCP  : ' + BoolToText(Adapters[I].DHCPEnabled));
  end;
end;

procedure TestPing;
begin
  Logger.Info('Ping', 'Pinging 8.8.8.8...');
  if PingHost('8.8.8.8', 2000) then
    Logger.Info('Ping', '8.8.8.8 reachable')
  else
    Logger.Warn('Ping', '8.8.8.8 unreachable');
end;

begin
  Logger := TLog.Create;
  try
    WriteLn('═══════════════════════════════════');
    WriteLn('  pspkg Pascal System Toolkit      ');
    WriteLn('═══════════════════════════════════');
    WriteLn;

    try
      ShowSystemInfo;
      WriteLn;
      TestNetwork;
      WriteLn;
      TestPing;
      WriteLn;
      Logger.Info('App', 'All tests complete.');
    except
      on E: Exception do
        Logger.ExceptionLog(E, 'App');
    end;
  finally
    Logger.Free;
  end;
end.
