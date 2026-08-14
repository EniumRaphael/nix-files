{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.immich;
in
{
  config = lib.mkIf cfg {
    age.secrets."immich-mail-password" = {
      file = ../../secrets/immich-mail-password.age;
      owner = "immich";
      group = "immich";
      mode = "0400";
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    users = {
      groups.datausers = { };
      users.immich.extraGroups = [
        "video"
        "render"
        "datausers"
      ];
    };
    systemd = {
      services.update-immich-containers = {
        script = ''
          containers=(immich-machine-learning)

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
        '';
        serviceConfig.Type = "oneshot";
      };
      timers.update-immich-containers = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "5min";
        };
      };
    };
    hardware.nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
    };
    virtualisation = {
      docker.enable = true;
      oci-containers = {
        backend = "docker";
        containers = {
          immich-machine-learning = {
            image = "ghcr.io/immich-app/immich-machine-learning:release-cuda";
            devices = [
              "nvidia.com/gpu=all"
            ];
            networks = [
              "host"
            ];
            volumes = [
              "/var/cache/immich:/cache"
            ];
            environment.TZ = "Europe/Paris";
          };
        };
      };
    };
    services = {
      immich = {
        enable = true;
        port = 2283;
        openFirewall = true;
        host = "127.0.0.1";
        mediaLocation = "/mnt/disks/immich";
        environment.MACHINE_LEARNING_URL = "http://localhost:3003";
        machine-learning.enable = false;
        redis.enable = true;
        settings = {
          server = {
            externalDomain = "https://immich.enium.eu";
            loginPageMessage = "Welcome to the cloud Enium";
            publicUsers = false;
          };
          notifications.smtp = {
            enabled = true;
            from = "immich@enium.eu";
            transport = {
              host = "smtp.migadu.com";
              ignoreCert = false;
              username = "immich@enium.eu";
              password._secret = config.age.secrets.immich-mail-password.path;
              port = 465;
              secure = true;
            };
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts."immich.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig = ''
              client_max_body_size 50000M;
              proxy_read_timeout   600s;
              proxy_send_timeout   600s;
              send_timeout         600s;
            '';
          };
        };
      };
    };
    systemd.tmpfiles.rules = [
        "d /mnt/disks 2770 root datausers -"
        "d /mnt/disks/immich 0750 immich immich -"
      ];
  };
}
