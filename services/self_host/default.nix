{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  git = import ./git.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  htop = import ./htop.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  jellyfin = import ./jellyfin.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  mail = import ./mail.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  matrix = import ./matrix.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  monitor = import ./monitor.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  ollama = import ./ollama.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  immich = import ./immich.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  nextcloud = import ./nextcloud.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  sso = import ./sso.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  vault = import ./vault.nix {
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
    matrix
    monitor
    nextcloud
    ollama
    immich
    sso
    vault
  ];

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
    matrix = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the matrix";
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
    immich = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the immich";
    };
    ollama = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the ollama";
    };
    sso = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the sso";
    };
    vault = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the vault";
    };
  };
}
