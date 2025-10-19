{ inputs, ... }:

{
  imports = [ inputs.agenix.nixosModules.default ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets."mailjet-user" = {
    file = ../../secrets/mailjet-user.age;
    owner = "root";
    group = "root";
    mode  = "0400";
  };
  age.secrets."mailjet-pass" = {
    file = ../../secrets/mailjet-pass.age;
    owner = "root";
    group = "root";
    mode  = "0400";
  };

  age.secrets."authentik-env" = {
    file = ../../secrets/authentik-env.age;
    owner = "root";
    group = "root";
    mode  = "0400";
  };

  age.secrets."auth-grafana-id" = {
    file  = ../../secrets/auth-grafana-id.age;
    owner = "root";
    group = "grafana";
    mode  = "0440";
  };
  age.secrets."auth-grafana-secret" = {
    file  = ../../secrets/auth-grafana-secret.age;
    owner = "root";
    group = "grafana";
    mode  = "0440";
  };

  age.secrets."auth-nextcloud-id" = {
    file  = ../../secrets/auth-nextcloud-id.age;
    owner = "root";
    group = "nextcloud";
    mode  = "0440";
  };
  age.secrets."auth-nextcloud-secret" = {
    file  = ../../secrets/auth-nextcloud-secret.age;
    owner = "root";
    group = "nextcloud";
    mode  = "0440";
  };
}
