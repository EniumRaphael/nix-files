{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.applications.mullvad;
  mullvad-autostart = pkgs.makeAutostartItem {
    name = "mullvad-vpn";
    package = pkgs.mullvad-vpn;
  };
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = [
      mullvad-autostart
    ];
    services = {
      mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
    };
  };
}
