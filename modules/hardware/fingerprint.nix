{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.fingerprint;
in
{
  config = lib.mkIf cfg {
    security.polkit = lib.mkIf config.graphical.laptop {
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "fprintd.service" &&
              subject.user == "raphael") {
            return polkit.Result.YES;
          }
        });
      '';
    };
    services = {
      udev = {
        packages = with pkgs; [
          libfprint-2-tod1-goodix
        ];
      };
      fprintd = {
        enable = true;
        package = pkgs.fprintd-tod;
        tod = {
          enable = true;
          driver = pkgs.libfprint-2-tod1-goodix;
        };
      };
    };
  };
}
