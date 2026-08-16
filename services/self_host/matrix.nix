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
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
      8448
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
            "127.0.0.1"
          ];
          port = [
            6167
          ];
          well_known.client = "https://${nddMatrix}";
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
        };
        well_known = {
          client.base_url = "https://${nddMatrix}";
          server.base_url = "https://${nddMatrix}";
        };
      };
      nginx = {
        enable = true;
        upstreams."tuwunel" = {
          servers = {
            "127.0.0.1:6167" = { };
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
      };
    };
  };
}
