{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.network;
  ipv6 = import ./ipv6.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    ipv6
  ];
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        systemd.network.enable = true;
        networking = {
          firewall.enable = true;
          useNetworkd = true;
          wireless.iwd = {
            enable = cfg.wireless;
            settings = {
              General = {
                AddressRandomization = "network";
              };
              Settings = {
                AutoConnect = true;
              };
            };
          };
        };
      }
      (lib.mkIf cfg.wireless {
        systemd.network.networks."25-wireless" = {
          matchConfig.Type = "wlan";
          networkConfig = {
            DHCP = "yes";
            IPv6PrivacyExtensions = "yes";
            IgnoreCarrierLoss = "3s";
          };
        };

        boot.extraModprobeConfig = ''
          options mt7925e disable_aspm=1
          options mt7925e power_save=0
        '';
      })
      (lib.mkIf cfg.resolved {
        services.resolved = {
          enable = true;
          settings.Resolve = {
            DNSOverTLS = "opportunistic";
            DNSSEC = "allow-downgrade";
          };
        };
        systemd.network.networks."25-wireless" = lib.mkIf cfg.wireless {
          dhcpV4Config.UseDNS = false;
          dhcpV6Config.UseDNS = false;
          ipv6AcceptRAConfig.UseDNS = false;
        };
      })
    ]
  );
}
