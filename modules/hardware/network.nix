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
    systemd.network = {
      enable = true;
      networks."25-wireless" = {
        matchConfig.Name = "wlan0";
        networkConfig.DHCP = "yes";
      };
    };
    networking = {
      firewall.enable = true;
      useNetworkd = true;
      wireless.iwd = {
        enable = true;
        settings = lib.mkIf cfg.wireless {
          General = {
            ControlPortOverNL80211 = false;
            AddressRandomization = "network";
            EnableNetworkConfiguration = true;
          };
          DriverQuirks.DefaultInterface = true;
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };
    systemd.services.mediatek-wifi-resume = lib.mkIf cfg.wireless {
      description = "Restart NetworkManager after suspend to fix MediaTek WiFi";
      wantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      after = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl restart NetworkManager.service";
      };
    };

    boot.extraModprobeConfig = lib.mkIf cfg.wireless ''
      options mt7925e disable_aspm=1
      options mt7925e power_save=0
      options mt7925-common disable_clc=1
    '';
  };
}
