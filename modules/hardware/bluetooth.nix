{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.bluetooth;
in
{
  config = lib.mkIf cfg {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
