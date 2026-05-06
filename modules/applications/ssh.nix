{
config,
pkgs,
lib,
...
}:

let
  sshKeyMac = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIML4yVz1fhccwaTL0iHixkNkU5zUWU1rsit9u2TIIa5r raphael@raphaels-MacBook-Pro.local";
  sshKeyFramework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlz8TaFYDbMiEmx3Pt5jEyHE169zImZTHTaP9IfhFCK raphael@nixos-fix";
  sshKeyFix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHqvUXdRS78wloWZnSqiOt63Gx0QRJdHxggrrepOd9+1 raphael@nixos-fix";
  cfg = config.applications.ssh;
in
  {
  config = lib.mkIf cfg {
    users.users.raphael.openssh.authorizedKeys.keys = [
      sshKeyMac
      sshKeyFramework
      sshKeyFix
    ];
    services = {
      openssh = {
        enable = true;
        ports = [
          42131
        ];
      };
    };
  };
}
