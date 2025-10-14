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
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wine-staging
      lutris
      dxvk
      vkd3d
    ];

    users = {
      groups.datausers = { };
      users = {
        raphael.extraGroups = [ "datausers" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/data 2770 root datausers -"
    ];

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
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
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
