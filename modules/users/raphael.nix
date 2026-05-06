{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-user.raphael;
in
{
  config = lib.mkIf cfg {
    users.users = {
      raphael = {
        isNormalUser = true;
        description = "Raphael";
        useDefaultShell = true;
        extraGroups = [
          "dialout"
          "docker"
          "input"
          "networkmanager"
          "plugdev"
          "render"
          "video"
          "wheel"
        ];
      };
    };
  };
}
