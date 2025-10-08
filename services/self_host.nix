{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  htop = import ./self_host/htop.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  mail = import ./self_host/mail.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  monitor = import ./self_host/monitor.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  teamspeak = import ./self_host/teamspeak.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  ollama = import ./self_host/ollama.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  nextcloud = import ./self_host/nextcloud.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  cfg = config.service.selfhost;
in
{
  imports = [
    nextcloud
    mail
    htop
    ollama
    teamspeak
    monitor
  ];

  config = {
    services.nginx = {
      enable = true;
    };
  };
  options.service.selfhost = {
    htop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the htop";
    };
    teamspeak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the teamspeak";
    };
    ollama = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the ollama";
    };
    mail = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the mail";
    };
    monitor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the monitor";
    };
    nextcloud = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the nextcloud";
    };
  };
}
