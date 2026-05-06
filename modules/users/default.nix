{
  config,
  pkgs,
  lib,
  ...
}:

let
  raphael = import ./raphael.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    raphael
  ];

  options.config-user = {
    raphael = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "raphael user configuration";
    };
  };
}
