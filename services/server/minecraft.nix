{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.server.minecraft;
in
{
  imports = [
    inputs.minecraft.nixosModules.minecraft-servers
  ];

  config = lib.mkIf cfg {
    nixpkgs.overlays = [
      inputs.minecraft.overlay
    ];
    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers.enium-pv = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_20_1;
        jvmOpts = "-Xms4092M -Xmx4092M";
        serverProperties = {
          difficulty = 3;
          gamemode = 0;
          max-players = 42;
          motd = "§l §3                       Enium Survival§r\n§l   §b                  Whitelisted Server";
          server-port = 64421;
          spawn-protection = 16;
          white-list = true;
        };
        restart = "no";
      };
    };
  };
}
