{
  config,
  pkgs,
  lib,
  ...
}:

let
  immichLogo = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/immich-app/immich/ffc83eae36034fe75525a0abd6c5df351184cd91/design/immich-logo.svg";
    name = "immich.svg";
    sha256 = "19hik27zb446syvzxpy0iw7p38mxfd0j433c60a4k1879mqfz9fz";
  };
  cfg = config.service.selfhost.immich;
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "immich-mail-password" = {
        file = ../../secrets/immich-mail-password.age;
        owner = "immich";
        group = "immich";
        mode = "0400";
      };
      "immich-oidc-secret" = {
        file = ../../secrets/immich-oidc-secret.age;
        owner = "kanidm";
        group = "immich";
        mode = "0440";
      };
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
          oauth = {
            enabled = true;
            issuerUrl = "https://auth.enium.eu/oauth2/openid/immich";
            clientId = "immich";
            clientSecret._secret = config.age.secrets.immich-oidc-secret.path;
            scope = "openid email profile";
            signingAlgorithm = "ES256";
            buttonText = "Se connecter avec Enium";
            autoRegister = true;
            autoLaunch = true;
            mobileOverrideEnabled = true;
            mobileRedirectUri = "app.immich:///oauth-callback";
            storageLabelClaim = "preferred_username";
          };
        };
      };

      kanidm.provision.systems.oauth2.immich = {
        present = true;
        displayName = "Immich";
        imageFile = immichLogo;
        originUrl = [
          "https://immich.enium.eu"
          "app.immich:///oauth-callback"
        ];
        originLanding = "https://immich.enium.eu/auth/login";
        basicSecretFile = config.age.secrets.immich-oidc-secret.path;
        public = false;
        enableLocalhostRedirects = false;
        allowInsecureClientDisablePkce = false;
        preferShortUsername = true;
        scopeMaps = {
          immich_users = [
            "email"
            "openid"
            "profile"
            "groups"
          ];
        };
        claimMaps = {
          groups = {
            joinType = "array";
            valuesByGroup = {
              immich_users = [
                "immich_users"
              ];
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
