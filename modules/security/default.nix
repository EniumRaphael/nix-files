{
  config,
  pkgs,
  lib,
  nixName,
  ...
}:

let
  apparmor = import ./apparmor.nix {
    inherit config pkgs lib;
  };
  autorun = import ./autorun.nix {
    inherit config pkgs lib nixName;
  };
  fail2ban = import ./fail2ban.nix {
    inherit config pkgs lib;
  };
  kernel = import ./kernel.nix {
    inherit config pkgs lib;
  };
  nginx = import ./nginx.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    apparmor
    autorun
    fail2ban
    kernel
    nginx
  ];

  options.config-sec = {
    autorun = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the autorun configuration";
    };
    apparmor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the apparmor configuration";
    };
    fail2ban = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the fail2ban configuration";
    };
    nginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the nginx configuration";
    };
    kernel = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the kernel configuration";
    };
  };
}
