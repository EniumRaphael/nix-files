{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  teamspeak = import ./server/teamspeak.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  minecraft = import ./server/minecraft.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
in
{
  imports = [
    minecraft
    teamspeak
  ];

  options.service.server = {
    teamspeak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the teamspeak";
    };
    minecraft = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable minecraft server";
    };
  };
}
