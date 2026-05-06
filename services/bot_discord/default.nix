{
  config,
  pkgs,
  lib,
  ...
}:

let
  master_bot = import ./master.nix {
    inherit config pkgs lib;
  };
  music_bot = import ./music.nix {
    inherit config pkgs lib;
  };
  tempvoc_bot = import ./tempvoc.nix {
    inherit config pkgs lib;
  };
  ada_bot = import ./ada.nix {
    inherit config pkgs lib;
  };
  tut_bot = import ./bot_loc.nix {
    inherit config pkgs lib;
  };
  bde_bot = import ./bde.nix {
    inherit config pkgs lib;
  };
  marty_bot = import ./marty.nix {
    inherit config pkgs lib;
  };
  ticket_bot = import ./ticket.nix {
    inherit config pkgs lib;
  };
  cfg = config.service.bot_discord;
in
{
  imports = [
    ada_bot
    bde_bot
    tut_bot
    master_bot
    music_bot
    tempvoc_bot
    ticket_bot
    marty_bot
  ];

  options.service.bot_discord = {
    master = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable master bot";
    };
    ada = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ada bot";
    };
    tut = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable tut bot";
    };
    bde = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable bde bot";
    };
    marty = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable marty bot";
    };
    music = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable music bot";
    };
    tempvoc = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tempvoc bot";
    };
    ticket = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ticket bot";
    };
  };
}
