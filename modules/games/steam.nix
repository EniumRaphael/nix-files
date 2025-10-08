{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.games.steam;
in
{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode.enable = true;

    systemd.user.services."steam-bp" = lib.mkIf cfg.bp {
      description = "Steam Big Picture auto start";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.steam}/bin/steam -tenfoot -fulldesktopres";
        Restart = "on-failure";
        Environment = [
          "SDL_VIDEO_X11_DGAMOUSE=0"
          "STEAM_USE_OGL=1"
          "GAMEMODERUNEXEC=1"
        ];
      };
    };

    services = {
      desktopManager.plasma6.enable = lib.mkIf cfg.bp true;
      displayManager = lib.mkIf cfg.bp {
        defaultSession = "plasmax11";
        sddm.enable = true;
        autoLogin = {
          enable = true;
          user = "raphael";
        };
      };
    };
  };
}
