{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  git = import ./self_host/git.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  htop = import ./self_host/htop.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  jellyfin = import ./self_host/jellyfin.nix {
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
  sso = import ./self_host/sso.nix {
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
    git
    jellyfin
    htop
    mail
    monitor
    nextcloud
    ollama
    sso
  ];

  config = {
    services.nginx = {
      enable = true;
    };
  };
  options.service.selfhost = {
    git = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the git";
    };
    htop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the htop";
    };
    jellyfin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the jellyfin";
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
    ollama = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the ollama";
    };
    sso = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the nextcloud";
    };
  };
}
