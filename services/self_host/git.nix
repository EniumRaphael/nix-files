{
  config,
  pkgs,
  lib,
  ...
}:

let
  gitDomain = "git.enium.eu";
  forgejoLogo = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/doc-sheet/forgejo/refs/heads/forgejo/assets/logo.svg";
    name = "forgejo.svg";
    sha256 = "sha256-rP7aZURtHBfF2OYuGLcKZhbvIN+B596T/3kaOxHUvig=";
  };
  cfg = config.service.selfhost.git;
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "forgejo-oidc-secret" = {
        file = ../../secrets/forgejo-oidc-secret.age;
        owner = "kanidm";
        group = "forgejo";
        mode = "0440";
      };

      "forgejo-runner-default-token" = {
        file = ../../secrets/forgejo-runner-default-token.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "forgejo-runner-rust-token" = {
        file = ../../secrets/forgejo-runner-rust-token.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "forgejo-runner-forty-two-token" = {
        file = ../../secrets/forgejo-runner-forty-two-token.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "forgejo-runner-nix-token" = {
        file = ../../secrets/forgejo-runner-nix-token.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "forgejo-runner-flutter-token" = {
        file = ../../secrets/forgejo-runner-flutter-token.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "forgejo-runner-docker-token" = {
        file = ../../secrets/forgejo-runner-docker-token.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "forgejo-mail-password" = {
        file = ../../secrets/forgejo-mail-password.age;
        owner = "forgejo";
        group = "forgejo";
        mode = "0440";
      };
    };

    services = {
      kanidm.provision.systems.oauth2.forjego = {
        present = true;
        displayName = "Forjego";
        imageFile = forgejoLogo;
        originUrl = "https://git.enium.eu";
        originLanding = "https://git.enium.eu/user/oauth2/Enium/callback";
        basicSecretFile = config.age.secrets.forgejo-oidc-secret.path;
        public = false;
        enableLocalhostRedirects = false;
        allowInsecureClientDisablePkce = true;
        preferShortUsername = true;
        scopeMaps = {
          forgejo_admins = [
            "email"
            "openid"
            "profile"
            "groups"
          ];
          forgejo_users = [
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
              forgejo_admins = [
                "forgejo_admins"
              ];
              forgejo_users = [
                "forgejo_users"
              ];
            };
          };
        };
      };
      forgejo = {
        enable = true;
        database.type = "postgres";

        settings = {
          server = {
            "DEFAULT.APP_NAME" = "Enium Git";
            "DEFAULT.APP_SLOGAN" = "Born2Code";
            DOMAIN = gitDomain;
            ROOT_URL = "https://${gitDomain}/";
            SSH_PORT = 42131;
            HTTP_ADDR = "::1";
            HTTP_PORT = 3042;
          };

          oauth2 = {
            ENABLED = true;
            NAME = "Enium";
            CLIENT_ID = "forgejo";
            CLIENT_SECRET = "${config.age.secrets.forgejo-oidc-secret.path}";
            SCOPES = "openid email profile groups";
            LOGIN_ATTRIBUTE_PATH = "preferred_username";
            AUTH_URL = "https://git.enium.eu/ui/oauth2";
            TOKEN_URL = "https://git.enium.eu/oauth2/token";
            API_URL = "https://git.enium.eu/oauth2/openid/forgejo/userinfo";
            REDIRECT_URI = "https://git.enium.eu/user/oauth2/Enium/callback";
            CODE_CHALLENGE_METHOD = "S256";
            ENABLE_AUTO_REGISTRATION = true;
            UPDATE_AVATAR = true;
          };

          service = {
            DISABLE_REGISTRATION = false;
            ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            SHOW_REGISTRATION_BUTTON = false;
            DISABLE_PASSWORD_SIGNIN_FORM = true;
          };
          security = {
            LOGIN_REMEMBER_DAYS = 14;
          };
          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "https://github.com";
          };
          mailer = {
            ENABLED = true;
            PROTOCOL = "smtps";
            SMTP_ADDR = "smtp.migadu.com";
            SMTP_PORT = 465;
            FROM = "git@enium.eu";
            USER = "git@enium.eu";
          };
        };
        secrets.mailer.PASSWD = config.age.secrets.forgejo-mail-password.path;
      };
      forgejo-runner.instances = {
        default = {
          enable = true;
          settings = {
            runner.labels = [
              "ubuntu-latest:docker://ubuntu:latest"
            ];
            server.connections.default = {
              url = "https://git.enium.eu";
              uuid = "362ea69f-4e4b-424d-9eb7-45e5de316dbb";
            };
          };
          secrets.server.connections.default.token_url =
            config.age.secrets."forgejo-runner-default-token".path;
        };
        rust = {
          enable = true;
          settings = {
            runner.labels = [
              "rust:docker://rust:alpine"
            ];
            server.connections.default = {
              url = "https://git.enium.eu";
              uuid = "3d8720af-e477-4549-a4ad-394756702a15";
            };
          };
          secrets.server.connections.default.token_url = config.age.secrets."forgejo-runner-rust-token".path;
        };
        docker = {
          enable = true;
          settings = {
            runner.labels = [
              "docker:docker://docker:dind"
            ];
            container = {
              privileged = true;
              options = "--dns=1.1.1.1 --dns=1.0.0.1";
              docker_host = "automount";
            };
            server.connections.default = {
              url = "https://${gitDomain}";
              uuid = "141201fc-b676-484f-82d1-a8b19b77f5fd";
            };
          };
          secrets.server.connections.default.token_url =
            config.age.secrets."forgejo-runner-docker-token".path;
        };
        forty-two = {
          enable = true;
          settings = {
            runner.labels = [
              "forty-two:docker://alexandregv/remote-42"
            ];
            server.connections.default = {
              url = "https://git.enium.eu";
              uuid = "7e7a16dd-893e-4c54-98d5-eb7c06b87a15";
            };
          };
          secrets.server.connections.default.token_url =
            config.age.secrets."forgejo-runner-forty-two-token".path;
        };
        nix = {
          enable = true;
          settings = {
            runner.labels = [
              "nix:docker://nixos/nix"
            ];
            container = {
              options = "-v forgejo-nix-store:/nix";
              valid_volumes = [
                "forgejo-nix-store"
              ];
            };
            server.connections.default = {
              url = "https://git.enium.eu";
              uuid = "d36e098d-ad8d-407c-9265-f78f4d634922";
            };
          };
          secrets.server.connections.default.token_url = config.age.secrets."forgejo-runner-nix-token".path;
        };
        flutter = {
          enable = true;
          settings = {
            runner.labels = [
              "flutter:docker://ghcr.io/cirruslabs/flutter:stable"
            ];
            server.connections.default = {
              url = "https://git.enium.eu";
              uuid = "c28489ce-2b14-4ea3-b13e-12d90835ebab";
            };
          };
          secrets.server.connections.default.token_url =
            config.age.secrets."forgejo-runner-flutter-token".path;
        };
      };
      nginx = {
        enable = true;
        virtualHosts."${gitDomain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://[::1]:3042";
            proxyWebsockets = true;
          };
        };
      };
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    virtualisation.oci-containers.containers.forgejo-dind = {
      image = "docker:dind";
      environment = {
        DOCKER_TLS_CERTDIR = "/certs";
      };
      volumes = [
        "forgejo-dind-certs:/certs"
        "forgejo-dind-data:/var/lib/docker"
      ];
      cmd = [
        "--bip=10.200.0.1/24"
        "--default-address-pool=base=10.201.0.0/16,size=24"
      ];
      extraOptions = [
        "--privileged"
        "--hostname=docker"
        "--dns=1.1.1.1"
        "--dns=1.0.0.1"
      ];
    };

    systemd = {
      services = {
        forgejo-dind-prune = {
          description = "Nettoyage du cache docker du runner dind";
          serviceConfig.Type = "oneshot";
          script = ''
            ${config.virtualisation.docker.package}/bin/docker exec forgejo-dind docker system prune -af --filter until=168h
          '';
        };
      };
      timers.forgejo-dind-prune = {
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
  };
}
