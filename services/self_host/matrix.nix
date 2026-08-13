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
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    age.secrets."matrix-oidc-secret" = {
        file = ../../secrets/matrix-oidc-secret.age;
        owner = "kanidm";
        group = "tuwunel";
        mode = "0440";
      };
    services = {
      kanidm.provision.systems.oauth2.matrix = {
        present = true;
        displayName = "Matrix";
        imageFile = matrixLogo;
        originUrl = "https://matrix.enium.eu";
        originLanding = "https://matrix.enium.eu/_matrix/client/unstable/login/sso/callback/matrix";
        basicSecretFile = config.age.secrets.matrix-oidc-secret.path;
        public = false;
        enableLocalhostRedirects = false;
        allowInsecureClientDisablePkce = false;
        preferShortUsername = true;
        scopeMaps = {
          matrix_user = [
            "email"
            "openid"
            "profile"
          ];
        };
      };
      matrix-tuwunel = {
        enable = true;
        settings.global = {
          server_name = "matrix.enium.eu";
          address = [
            "127.0.0.1"
          ];
          port = [
            6167
          ];
          well_known.client = "https://matrix.enium.eu";
          allow_federation = true;
          identity_provider = [{
            brand = "Enium";
            client_id = "matrix";
            client_secret_file = config.age.secrets.matrix-oidc-secret.path;
            default = true;
            scopes = [ "openid" "email" "profile" ];
            issuer_url = "https://auth.enium.eu/oauth2/openid/matrix";
            callback_url = "https://matrix.enium.eu/_matrix/client/oidc/callback";
            userid_claims = [ "preferred_username" ];
            trusted = true;
            registration = true;
            unique_id_fallbacks = false;
          }];
        };
      };
      nginx = {
        enable = true;
        virtualHosts."matrix.enium.eu" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:6167";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
