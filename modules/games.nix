{
  config,
  pkgs,
  lib,
  ...
}:

let
  steam = import ./games/steam.nix {
    inherit config pkgs lib;
  };
  lutris = import ./games/lutris.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    lutris
    steam
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
