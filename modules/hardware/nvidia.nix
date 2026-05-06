{
config,
pkgs,
lib,
...
}:

let
  cfg = config.config-hw.nvidia;
in
  {
  config = lib.mkIf cfg {
    hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    services = {
      xserver.videoDrivers = [ "nvidia" ];
    };
  };
}
