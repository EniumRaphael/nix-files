{
config,
pkgs,
lib,
...
}:
let
  cfg = config.service.selfhost.jellyfin;
  wireguard-key = config.age.secrets."wireguard-secret".path;
in
  {
  config = lib.mkIf cfg {
    virtualisation = {
      docker.enable = true;
      oci-containers = {
        backend = "docker";
        containers = {
          gluetun = {
            image = "qmcgaw/gluetun:latest";
            autoStart = true;
            extraOptions = [
              "--cap-add=NET_ADMIN"
              "--device=/dev/net/tun"
            ];
            environment = {
              VPN_SERVICE_PROVIDER = "mullvad";
              VPN_TYPE = "wireguard";
              WIREGUARD_PRIVATE_KEY = builtins.readFile wireguard-key;
              BLOCK_MALICIOUS = "off";
              BLOCK_SURVEILLANCE = "off";
              BLOCK_ADS = "off";
              WIREGUARD_ADDRESSES = "10.70.168.94/32";
              SERVER_COUNTRIES = "Sweden";
              SERVER_CITIES = "Stockholm";
              SERVER_HOSTNAMES = "se-sto-wg-206";
              TZ = "Europe/Paris";
            };
            ports = [
              "8080:8080"
              "7878:7878"
              "8989:8989"
              "9696:9696"
            ];
          };
          qbittorrent = {
            image = "lscr.io/linuxserver/qbittorrent:latest";
            autoStart = true;
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              WEBUI_PORT = "8080";
              TZ = "Europe/Paris";
            };
            volumes = [
              "/mnt/data/qbittorrent/config:/config"
              "/mnt/data/downloads:/downloads"
            ];
          };
          radarr = {
            image = "lscr.io/linuxserver/radarr:latest";
            autoStart = true;
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              TZ = "Europe/Paris";
            };
            volumes = [
              "/mnt/data/radarr/config:/config"
              "/mnt/data/downloads:/downloads"
              "/mnt/data:/data"
            ];
          };
          sonarr = {
            image = "lscr.io/linuxserver/sonarr:latest";
            autoStart = true;
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              TZ = "Europe/Paris";
            };
            volumes = [
              "/mnt/data/sonarr/config:/config"
              "/mnt/data/downloads:/downloads"
              "/mnt/data:/data"
            ];
          };
          prowlarr = {
            image = "lscr.io/linuxserver/prowlarr:latest";
            autoStart = true;
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              TZ = "Europe/Paris";
            };
            volumes = [
              "/mnt/data/prowlarr/config:/config"
            ];
          };
        };
      };
    };
    users = {
      groups.datausers = { };
      users = {
        jellyfin.extraGroups = [ "datausers" ];
      };
    };
    services = {
      jellyfin = {
        enable = true;
        dataDir = "/mnt/data/jellyfin";
        openFirewall = true;
      };
      nginx.virtualHosts = {
        "jellyfin.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
          };
        };
        "radarr.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:7878";
          };
        };
        "sonarr.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8989";
          };
        };
      };
    };
  };
}
