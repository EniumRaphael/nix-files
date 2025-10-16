{ config, pkgs, inputs, ... }:
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
}
