{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.network;
in
{
  config = lib.mkIf cfg.enable {
    networking = {
      firewall.enable = true;
      networkmanager = {
        enable = true;
        wifi = lib.mkIf cfg.wireless {
          powersave = false;
          macAddress = "preserve";
        };
      };
    };
  };
}
