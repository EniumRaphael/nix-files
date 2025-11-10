{
config,
pkgs,
lib,
...
}:
let
  cfg = config.service.selfhost.jellyfin;
in
  {
  config = lib.mkIf cfg {
    services = {
      jellyfin = 
        {
          enable = true;
          dataDir = "/mnt/data/media";
          openFirewall = true;
        };

      qbittorrent = {
        enable = true;
        dataDir = "/mnt/data/downloads";
        webui.port = 8137;
      };

      radarr = {
        enable = true;
        dataDir = "/var/lib/radarr";
        user = "radarr";
        group = "media";
        openFirewall = true;
      };

      prowlarr = {
        enable = true;
        dataDir = "/var/lib/prowlarr";
        openFirewall = true;
      };

      bazarr.enable = true;
    };
  };
}
