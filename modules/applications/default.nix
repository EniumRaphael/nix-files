{
  config,
  pkgs,
  lib,
  ...
}:

let
  docker = import ./docker.nix {
    inherit config pkgs lib;
  };
  man = import ./man.nix {
    inherit config pkgs lib;
  };
  mullvad = import ./mullvad.nix {
    inherit config pkgs lib;
  };
  ssh = import ./ssh.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    docker
    man
    mullvad
    ssh
  ];

  options.applications = {
    docker = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the docker configuration";
    };
    man = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the man configuration";
    };
    mullvad = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the mullvad configuration";
    };
    ssh = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the ssh configuration";
    };
  };
}
