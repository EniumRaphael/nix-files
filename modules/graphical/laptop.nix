{
config,
pkgs,
lib,
...
}:

let
  cfg = config.graphical.laptop;
in
  {
  config = lib.mkIf cfg {
    security = {
      pam.services = {
        greetd = {
          fprintAuth = true;
        };
        login.fprintAuth = true;
        sudo.fprintAuth = true;
        hyprlock.text = ''
          auth sufficient pam_fprintd.so
          auth include login
        '';
      };
    };
  };
}
