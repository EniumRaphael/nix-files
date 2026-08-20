{
  config,
  lib,
  ...
}:

let
  cfg = config.config-hw.streamdeck;
in
{
  config = lib.mkIf cfg {
    programs.streamdeck-ui = {
      enable = cfg;
      autoStart = cfg;
    };
  };
}
