let
  main-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgMdbjhUzi2VMEVNS/YHOwl9XgCsUKI6316b6gUS9ub root@nixos";
  systems = [
    main-server
  ];

  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBr42DzbasU7IjbujPC76Ngp8S3zlhDmMTHjjdl26GuW root@nixos-server";
  users = [
    root
  ];
in
{
  "wireguard-secret.age".publicKeys = users ++ systems;
  "mailjet-user.age".publicKeys = users ++ systems;
  "mailjet-pass.age".publicKeys = users ++ systems;
  "nextcloud-admin-pass.age".publicKeys = users ++ systems;
  "nextcloud-database.age".publicKeys = users ++ systems;
  "nextcloud-oidc-secret.age".publicKeys = users ++ systems;
  "grafana-oidc-secret.age".publicKeys = users ++ systems;
  "forgejo-oidc-secret.age".publicKeys = users ++ systems;
  "kandim-admin.age".publicKeys = users ++ systems;
  "kandim-idmAdmin.age".publicKeys = users ++ systems;
}
