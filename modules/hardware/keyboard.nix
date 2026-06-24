{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.keyboard;
in
{
  config = lib.mkIf cfg {
    hardware.keyboard.zsa.enable = true;
    environment.systemPackages = with pkgs; [
      keymapp
    ];
  };
}
