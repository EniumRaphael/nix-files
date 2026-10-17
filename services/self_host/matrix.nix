{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.matrix;
  matrixLogo = pkgs.fetchurl {
    url = "https://matrix.org/images/matrix-logo-white.svg";
    name = "matrix.svg";
    sha256 = "0qp0k19gsw65ymnikdmkn3n32l3x7v8szf4ijlzsla92szn0vwhk";
  };
  nddMatrix = "matrix.enium.eu";
  nddAuth = "auth.enium.eu";
  nddTurn = "turn.enium.eu";
  nddMatrixRtc = "matrix-rtc.enium.eu";
  rtcPublicIp = "2a01:e0a:e77:13f1::1";
  deniedPeers = [
    "0.0.0.0-0.255.255.255"
    "10.0.0.0-10.255.255.255"
    "100.64.0.0-100.127.255.255"
    "127.0.0.0-127.255.255.255"
    "169.254.0.0-169.254.255.255"
    "172.16.0.0-172.31.255.255"
    "192.0.0.0-192.0.0.255"
    "192.0.2.0-192.0.2.255"
    "192.88.99.0-192.88.99.255"
    "192.168.0.0-192.168.255.255"
    "198.18.0.0-198.19.255.255"
    "198.51.100.0-198.51.100.255"
    "203.0.113.0-203.0.113.255"
    "240.0.0.0-255.255.255.255"
    "::1"
    "64:ff9b::-64:ff9b::ffff:ffff"
    "::ffff:0.0.0.0-::ffff:255.255.255.255"
    "100::-100::ffff:ffff:ffff:ffff"
    "2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff"
    "2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
    "fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
    "fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
  ];
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
      3478
      5349
      7881
      8448
    ];
    networking.firewall.allowedUDPPorts = [
      443
      3478
      5349
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 49152;
        to = 50175;
      }
      {
        from = 50200;
        to = 51200;
      }
    ];
    age.secrets = {
      "matrix-registration-token" = {
        file = ../../secrets/matrix-registration-token.age;
        owner = "tuwunel";
        group = "tuwunel";
        mode = "0400";
      };
      "matrix-oidc-secret" = {
        file = ../../secrets/matrix-oidc-secret.age;
        owner = "kanidm";
        group = "tuwunel";
        mode = "0440";
      };
      "matrix-turn-secret" = {
        file = ../../secrets/matrix-turn-secret.age;
        owner = "turnserver";
        group = "tuwunel";
        mode = "0440";
      };
      "livekit-keys" = {
        file = ../../secrets/livekit-keys.age;
      };
    };
    services = {
      kanidm.provision.systems.oauth2.matrix = {
        present = true;
        displayName = "Matrix";
        imageFile = matrixLogo;
        originUrl = "https://${nddMatrix}";
        originLanding = "https://${nddMatrix}/_matrix/client/unstable/login/sso/callback/matrix";
        basicSecretFile = config.age.secrets.matrix-oidc-secret.path;
        public = false;
        enableLocalhostRedirects = false;
        allowInsecureClientDisablePkce = false;
        preferShortUsername = true;
        scopeMaps = {
          matrix_users = [
            "email"
            "openid"
            "profile"
          ];
        };
      };
      matrix-tuwunel = {
        enable = true;
        settings.global = {
          server_name = "${nddMatrix}";
          new_user_displayname_suffix = "";
          address = [
            "::1"
          ];
          port = [
            6167
          ];
          allow_federation = true;
          identity_provider = [
            {
              brand = "Enium";
              client_id = "matrix";
              client_secret_file = config.age.secrets.matrix-oidc-secret.path;
              default = true;
              scopes = [
                "openid"
                "email"
                "profile"
              ];
              issuer_url = "https://${nddAuth}/oauth2/openid/matrix";
              userid_claims = [ "preferred_username" ];
              trusted = true;
              registration = true;
              registration_token_file = config.age.secrets.matrix-registration-token.path;
              unique_id_fallbacks = false;
            }
          ];
          turn_uris = [
            "turn:${nddTurn}:3478?transport=udp"
            "turn:${nddTurn}:3478?transport=tcp"
            "turns:${nddTurn}:5349?transport=tcp"
          ];
          turn_secret_file = config.age.secrets.matrix-turn-secret.path;
          turn_ttl = 86400;
          well_known = {
            client = "https://${nddMatrix}";
            server = "${nddMatrix}:443";
            livekit_url = "https://${nddMatrixRtc}";
          };
        };
      };
      coturn = {
        enable = true;
        use-auth-secret = true;
        static-auth-secret-file = config.age.secrets.matrix-turn-secret.path;
        realm = nddTurn;
        cert = "/var/lib/acme/${nddTurn}/fullchain.pem";
        pkey = "/var/lib/acme/${nddTurn}/key.pem";
        listening-ips = [ rtcPublicIp ];
        relay-ips = [ rtcPublicIp ];
        min-port = 49152;
        max-port = 50175;
        no-cli = true;
        extraConfig = ''
          fingerprint
          no-multicast-peers
          ${lib.concatMapStringsSep "\n" (r: "denied-peer-ip=${r}") deniedPeers}
        '';
      };
      livekit = {
        enable = true;
        keyFile = config.age.secrets.livekit-keys.path;
        settings = {
          port = 7880;
          rtc = {
            port_range_start = 50200;
            port_range_end = 51200;
            node_ip = rtcPublicIp;
          };
        };
      };
      lk-jwt-service = {
        enable = true;
        livekitUrl = "wss://${nddMatrixRtc}";
        keyFile = config.age.secrets.livekit-keys.path;
      };
      nginx = {
        enable = true;
        upstreams."tuwunel" = {
          servers = {
            "[::1]:6167" = { };
          };
        };
        virtualHosts."${nddMatrix}" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 443;
              ssl = true;
            }
            {
              addr = "[::]";
              port = 443;
              ssl = true;
            }
            {
              addr = "0.0.0.0";
              port = 8448;
              ssl = true;
            }
            {
              addr = "[::]";
              port = 8448;
              ssl = true;
            }
          ];
          http2 = true;
          http3 = true;
          extraConfig = ''
            client_max_body_size 100M;
          '';
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://tuwunel";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header X-Forwarded-Proto https;
            '';
          };
        };
        virtualHosts."${nddTurn}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            extraConfig = "return 200 '${nddTurn}';";
          };
        };
        virtualHosts."${nddMatrixRtc}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "~ ^/(sfu/get|get_token|healthz)" = {
              proxyPass = "http://[::1]:8089";
            };
            "/.well-known/foci" = {
              proxyPass = "http://[::1]:8089";
            };
            "/" = {
              proxyPass = "http://[::1]:7880";
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_read_timeout 300s;
              '';
            };
          };
        };
      };
    };
    users.users.turnserver.extraGroups = [ "nginx" ];
    security.acme.certs."${nddTurn}".postRun = "systemctl restart coturn || true";
    systemd.services.lk-jwt-service.environment = {
      LIVEKIT_JWT_BIND = lib.mkForce "[::1]:8089";
      LIVEKIT_FULL_ACCESS_HOMESERVERS = "matrix.enium.eu";
    };
  };
}
