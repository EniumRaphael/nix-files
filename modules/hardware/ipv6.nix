{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.config-hw.network.version6;
in
{
  config = lib.mkIf cfg.enable {
    networking = {
      enableIPv6 = true;
      tempAddresses = "disabled";

      interfaces.${cfg.interface}.ipv6.addresses = [
        {
          address = cfg.address;
          prefixLength = 64;
        }
      ];

      defaultGateway6 = {
        address = cfg.addressLocalLink;
        interface = cfg.interface;
      };

      dhcpcd.extraConfig = ''
        noipv6rs
        noipv6
      '';
    };

    boot.kernel.sysctl = {
      "net.ipv6.conf.${cfg.interface}.accept_ra" = 0;
      "net.ipv6.conf.${cfg.interface}.autoconf" = 0;
    };
    systemd.network.networks."40-${cfg.interface}" = {
      matchConfig.Name = cfg.interface;
      networkConfig = {
        DHCP = lib.mkForce "ipv4";
        IPv6AcceptRA = false;
      };
    };
  };
}
