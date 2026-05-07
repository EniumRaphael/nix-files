{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-sec.apparmor;
in
{
  config = lib.mkIf cfg {
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };

    security.audit.enable = true;
  };
}
