{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.service.selfhost.jellyfin;
  data_dir = "/mnt/disks";

  tz = "Europe/Paris";
  puid = "1000";
  pgid = "991";

  arrNetwork = "arr";
  arrSubnet = "172.30.0.0/24";
  arrGateway = "172.30.0.1";

  viaVpn = [ "--network=container:gluetun" ];

  vpnContainers = [
    "qbittorrent"
    "flaresolverr"
    "prowlarr"
    "sonarr"
    "radarr"
    "bazarr"
    "recyclarr"
  ];
  arrContainers = [ "gluetun" ] ++ vpnContainers ++ [ "seerr" ];

  lsioEnv = {
    PUID = puid;
    PGID = pgid;
    TZ = tz;
    UMASK = "002";
  };

  mkProxy = port: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  recyclarrConfig = pkgs.writeText "recyclarr.yml" ''
    sonarr:
      series:
        base_url: http://localhost:8989
        api_key: !env_var SONARR_API_KEY
        quality_definition:
          type: series
        quality_profiles:
          - trash_id: 72dae194fc92bf828f32cde7744e51a1
            reset_unmatched_scores:
              enabled: true

    radarr:
      movies:
        base_url: http://localhost:7878
        api_key: !env_var RADARR_API_KEY
        quality_definition:
          type: movie
        quality_profiles:
          - trash_id: d1d67249d3890e49bc12e275d989a7e9
            reset_unmatched_scores:
              enabled: true
  '';

  dockerUnits = lib.genAttrs (map (name: "docker-${name}") arrContainers) (_: {
    after = [
      "zfs-mount.service"
      "docker-network-arr.service"
    ];
    requires = [
      "zfs-mount.service"
      "docker-network-arr.service"
    ];
  });
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "wireguard-secret" = {
        file = ../../secrets/wireguard-secret.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
      "arr-api-keys" = {
        file = ../../secrets/arr-api-keys.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    virtualisation = {
      docker.enable = true;
      oci-containers = {
        backend = "docker";
        containers = {
          gluetun = {
            image = "qmcgaw/gluetun:latest";
            autoStart = true;
            extraOptions = [
              "--network=${arrNetwork}"
              "--cap-add=NET_ADMIN"
              "--device=/dev/net/tun"
            ];
            environmentFiles = [
              config.age.secrets."wireguard-secret".path
            ];
            environment = {
              VPN_SERVICE_PROVIDER = "mullvad";
              VPN_TYPE = "wireguard";
              BLOCK_MALICIOUS = "off";
              BLOCK_SURVEILLANCE = "off";
              BLOCK_ADS = "off";
              WIREGUARD_ADDRESSES = "10.68.171.41/32";
              SERVER_COUNTRIES = "Netherlands";
              TZ = tz;
              DNS_ADDRESS = "10.64.0.1";
              FIREWALL_INPUT_PORTS = "8080,8989,7878,9696,6767";
              FIREWALL_OUTBOUND_SUBNETS = arrSubnet;
            };
            ports = [
              "192.168.1.1:8080:8080"
              "127.0.0.1:8989:8989"
              "127.0.0.1:7878:7878"
              "192.168.1.1:9696:9696"
              "192.168.1.1:6767:6767"
            ];
          };

          qbittorrent = {
            image = "lscr.io/linuxserver/qbittorrent:latest";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            extraOptions = viaVpn;
            environment = lsioEnv // {
              WEBUI_PORT = "8080";
            };
            volumes = [
              "${data_dir}/qbittorrent/config:/config"
              "${data_dir}:/data"
            ];
          };

          flaresolverr = {
            image = "ghcr.io/flaresolverr/flaresolverr:latest";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            extraOptions = viaVpn;
            environment = {
              TZ = tz;
              LOG_LEVEL = "info";
            };
          };

          prowlarr = {
            image = "lscr.io/linuxserver/prowlarr:latest";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            extraOptions = viaVpn;
            environment = lsioEnv;
            volumes = [
              "${data_dir}/prowlarr/config:/config"
            ];
          };

          radarr = {
            image = "lscr.io/linuxserver/radarr:latest";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            extraOptions = viaVpn;
            environment = lsioEnv;
            volumes = [
              "${data_dir}/radarr/config:/config"
              "${data_dir}:/data"
            ];
          };

          sonarr = {
            image = "lscr.io/linuxserver/sonarr:latest";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            extraOptions = viaVpn;
            environment = lsioEnv;
            volumes = [
              "${data_dir}/sonarr/config:/config"
              "${data_dir}:/data"
            ];
          };

          bazarr = {
            image = "lscr.io/linuxserver/bazarr:latest";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            extraOptions = viaVpn;
            environment = lsioEnv;
            volumes = [
              "${data_dir}/bazarr/config:/config"
              "${data_dir}:/data"
            ];
          };

          recyclarr = {
            image = "ghcr.io/recyclarr/recyclarr:8";
            autoStart = true;
            dependsOn = [ "gluetun" ];
            user = "${puid}:${pgid}";
            extraOptions = viaVpn;
            environmentFiles = [
              config.age.secrets."arr-api-keys".path
            ];
            environment = {
              TZ = tz;
              CRON_SCHEDULE = "@daily";
            };
            volumes = [
              "${data_dir}/recyclarr/config:/config"
              "${recyclarrConfig}:/config/recyclarr.yml:ro"
            ];
          };

          seerr = {
            image = "ghcr.io/seerr-team/seerr:latest";
            autoStart = true;
            user = "${puid}:${pgid}";
            extraOptions = [
              "--network=${arrNetwork}"
              "--init"
            ];
            environment = {
              TZ = tz;
            };
            volumes = [
              "${data_dir}/seerr/config:/app/config"
            ];
            ports = [ "127.0.0.1:5055:5055" ];
          };
        };
      };
    };

    hardware.graphics.enable = true;
    boot.kernelModules = [ "nvidia_uvm" ];

    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg
      nvtopPackages.nvidia
    ];

    users = {
      groups.datausers.gid = lib.toInt pgid;
      users.jellyfin.extraGroups = [
        "datausers"
        "video"
        "render"
      ];
    };

    services = {
      xserver.videoDrivers = [ "nvidia" ];
      jellyfin = {
        enable = true;
        dataDir = "${data_dir}/jellyfin";
        cacheDir = "${data_dir}/jellyfin/cache";
        openFirewall = true;
      };
      nginx = {
        enable = true;
        virtualHosts = {
          "jellyfin.infra.parodi.tech" = mkProxy 8096;
          "radarr.infra.parodi.tech" = mkProxy 7878;
          "sonarr.infra.parodi.tech" = mkProxy 8989;
          "seerr.infra.parodi.tech" = mkProxy 5055;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    systemd = {
      services = dockerUnits // {
        docker-network-arr = {
          description = "Réseau Docker de la suite arr";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            ${pkgs.docker}/bin/docker network inspect ${arrNetwork} >/dev/null 2>&1 \
              || ${pkgs.docker}/bin/docker network create \
                   --subnet ${arrSubnet} --gateway ${arrGateway} ${arrNetwork}
          '';
        };

        jellyfin = {
          after = [
            "zfs-mount.service"
            "network-online.target"
          ];
          requires = [ "zfs-mount.service" ];
          unitConfig = {
            RequiresMountsFor = [
              "${data_dir}/movies"
              "${data_dir}/jellyfin/config"
              "${data_dir}/jellyfin/log"
            ];
          };
        };

        update-arr-containers = {
          script = ''
            containers=(${lib.concatStringsSep " " arrContainers})

            for container in "''${containers[@]}"; do
              image=$(${pkgs.docker}/bin/docker inspect --format='{{.Config.Image}}' "$container")
              echo "Pulling $image..."
              ${pkgs.docker}/bin/docker pull "$image"
            done

            for container in "''${containers[@]}"; do
              echo "Restarting $container..."
              systemctl restart "docker-$container.service"
              sleep 2
            done

            ${pkgs.docker}/bin/docker image prune -f
          '';
          serviceConfig.Type = "oneshot";
        };
      };

      timers.update-arr-containers = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "5min";
        };
      };

      tmpfiles.rules = [
        "d ${data_dir} 2770 root datausers -"
        "d ${data_dir}/downloads 2770 jellyfin datausers -"
        "d ${data_dir}/downloads/radarr 2770 jellyfin datausers -"
        "d ${data_dir}/downloads/tv-sonarr 2770 jellyfin datausers -"
        "d ${data_dir}/seerr/config 2770 ${puid} datausers -"
        "d ${data_dir}/recyclarr/config 2770 ${puid} datausers -"
      ];
    };
  };
}
