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
        autoStart = true;
        package = pkgs.fabricServers.fabric-1_21_11;
        restart = "always";
        jvmOpts = "-Xms2048M -Xmx8192M";
        serverProperties = {
          difficulty = 2;
          gamemode = 0;
          max-players = 42;
          motd = "§l §3                       Enium Survival§r\n§l   §b                  Whitelisted Server";
          server-port = 25565;
          spawn-protection = 0;
          white-list = true;
        };
        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
            graves = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/kieAM9Us/versions/YiPkk2xn/ly-graves-v3.0.1.jar";
              sha512 = "sha512-Wo+Sw6nVyqcaS7PWr+p3/+AkTYGAcuqk7heyBos/0jQYkCS/Z9q4Or6DInECkv8Cg4ZctmzrLOt6S8nr/sQYHw==";
            };
            lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/gl30uZvp/lithium-fabric-0.21.2%2Bmc1.21.11.jar";
              sha512 = "sha512-lGJVEAE+DarxwuK22KRjyTL/YiD5G6WwzV+GhlghXwRtlNB7NGVmD1dsTcJ6WqGD373ByTA/EYlLWyWh3Gw7tg==";
            };
            jei = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/9i2DXscL/jei-1.21.11-fabric-27.3.0.14.jar";
              sha512 = "sha512-ua8at0LkNpFFIleVM6D6GQthBZvuIh7rt8GSuY0mKjMIJ+dJr5G0wIKqcnsT8oBwkQvlWuitfWAz/cnM1maM9A==";
            };
            jade = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/nvQzSEkH/versions/7cBo3s22/Jade-1.21.11-Fabric-21.0.1.jar";
              sha512 = "sha512-aj1lnOyaPiH+AG6HYN6mNQtkqm1xGA+PCHouKn2U3t2mpfJ+r7+T3nCtxgbHXAe9/NncJb46Ds9ZTgIt7odRGw==";
            };
            chuncky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/1CpEkmcD/Chunky-Fabric-1.4.55.jar";
              sha512 = "sha512-O+DgSePepiVrOVzLH33MycayPLex9qcXp80cpV+dvaSJZ53zKGjHJmTrsoygXyw2ZZDR4aEfDcX2n5R5A7rYMw==";
            };
            fabric_api = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/gB6TkYEJ/fabric-api-0.140.2%2B1.21.11.jar";
              sha512 = "sha512-r0RleX2AQBAhpq78jFRyAOfA+MrhNCmb8/r7wxD6gfBVJGsGFPwOA3U49KhE5VqtMKv6PGdGBCKFPfxCbwhtAA==";
            };
            create_fly = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/dKvj0eNn/versions/be2IkC5H/create-fly-1.21.11-6.0.8-4.jar";
              sha512 = "1r9qx8q5s49xlycs9k02ylb0cgn5x0d3s0crl0942kwf2r6vvnk8pv46bxj6p4jnqg4r5c6b4526zjxwdjc1d5fg7613sgv6f71817x";
            };
          });
        };
        whitelist = {
          EniumRaphael = "3134072d-eb2f-49d5-afb4-2a3cc4375100";
          EniumBenjamin = "63e7d8d3-5090-4323-a7e6-c89707747b4b";
          EniumTeam = "d4706408-ccfc-4a3d-b128-07db95b34843";
          Zeldraft = "01cf2ab1-68a5-48c1-a948-76cda9574ae5";
          dprive05 = "0ad8a45a-417a-40d3-aa10-b67765792c42";
        };
        operators = {
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
