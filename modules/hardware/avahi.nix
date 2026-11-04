{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.avahi;
in
{
  config = lib.mkIf cfg {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = false;
    };
  };
}
