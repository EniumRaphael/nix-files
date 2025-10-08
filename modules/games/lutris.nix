{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.games.lutris;
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      wine-staging
      lutris
      dxvk
      vkd3d
    ];
  };
}
