let
  main-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEEuBgdANmzr69bapLdSxu6gnsLHGUQUBatS2dQsdOU root@nixos";
  systems = [
    main-server
  ];

  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQRq2M+a40lucGpjiWsWnjeUfA0ihzdtqyDbKznawAg root@nixos-server";
  users = [
    root
  ];
in
{
  "mailjet-user.age".publicKeys = users ++ systems;
  "mailjet-pass.age".publicKeys = users ++ systems;
  "authentik-env.age".publicKeys = users ++ systems;
  "auth-nextcloud-id.age".publicKeys = users ++ systems;
  "auth-nextcloud-secret.age".publicKeys = users ++ systems;
  "auth-grafana-id.age".publicKeys = users ++ systems;
  "auth-grafana-secret.age".publicKeys = users ++ systems;
}
