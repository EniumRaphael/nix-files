{ inputs, ... }:

{
  imports = [ inputs.agenix.nixosModules.default ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets."wireguard-secret" = {
    file = ../../secrets/wireguard-secret.age;
    owner = "root";
    group = "root";
    mode  = "0400";
  };

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

  age.secrets."nextcloud-admin-pass" = {
    file = ../../secrets/nextcloud-admin-pass.age;
    owner = "nextcloud";
    group = "nextcloud";
    mode  = "0400";
  };

  age.secrets."nextcloud-oidc-secret" = {
    file = ../../secrets/nextcloud-oidc-secret.age;
    owner = "kanidm";
    group = "kanidm";
    mode  = "0400";
  };

  age.secrets."grafana-oidc-secret" = {
    file = ../../secrets/grafana-oidc-secret.age;
    owner = "kanidm";
    group = "grafana";
    mode  = "0440";
  };

  age.secrets."forgejo-oidc-secret" = {
    file = ../../secrets/forgejo-oidc-secret.age;
    owner = "kanidm";
    group = "forgejo";
    mode  = "0440";
  };

  age.secrets."nextcloud-database" = {
    file = ../../secrets/nextcloud-database.age;
    owner = "nextcloud";
    group = "nextcloud";
    mode  = "0400";
  };

  age.secrets."kanidm-admin" = {
    file = ../../secrets/kandim-admin.age;
    owner = "kanidm";
    group = "kanidm";
    mode  = "0400";
  };

  age.secrets."kanidm-idmAdmin" = {
    file = ../../secrets/kandim-idmAdmin.age;
    owner = "kanidm";
    group = "kanidm";
    mode  = "0400";
  };

}
