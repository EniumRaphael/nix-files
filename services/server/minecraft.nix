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

      servers.enium-skyblock = {
        enable = true;
        autoStart = true;
        package = pkgs.minecraftServers.vanilla-1_21_11;
        restart = "always";
        jvmOpts = "-Xms2048M -Xmx8192M";
        serverProperties = {
          difficulty = 2;
          gamemode = 0;
          max-players = 2;
          motd = "§l §3                       Enium Survival§r\n§l   §b                  Whitelisted Server";
          server-port = 25565;
          spawn-protection = 0;
          white-list = true;
        };
        symlinks = {
          "world/datapacks/skyblock.zip" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/YVMr2l79/versions/iA5pxEc0/Skyblock_Infinite_1_1_12.zip";
            sha256 = "sha256-Dkw7Q+iOGnlHxeyu0gKjdOqKmNSUd4FngeMM44WHFUI=";
          };
        };
        whitelist = {
          Zeldraft = "01cf2ab1-68a5-48c1-a948-76cda9574ae5";
          dprive05 = "0ad8a45a-417a-40d3-aa10-b67765792c42";
        };
        operators = {
          dprive05 = {
            uuid = "0ad8a45a-417a-40d3-aa10-b67765792c42";
            level = 4;
            bypassesPlayerLimit = true;
          };
          Zeldraft = {
            uuid = "01cf2ab1-68a5-48c1-a948-76cda9574ae5";
            level = 4;
            bypassesPlayerLimit = true;
          };
        };
      };
    };
  };
}
