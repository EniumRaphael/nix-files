{
  config,
  pkgs,
  lib,
  ...
}:

let
  lutris = import ./lutris.nix {
    inherit config pkgs lib;
  };
  cfg = config.games;
in
{
  imports = [
    lutris
  ];

  options.games = {
    steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable steam installation";
      };
      bp = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the autostart of steam in big picture";
      };
    };
    lutris = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable lutris";
    };
  };
}
