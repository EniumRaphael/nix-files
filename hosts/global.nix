{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };

  time.timeZone = "Europe/Paris";

  security.pam.services.swaylock = { };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      raphael = {
        isNormalUser = true;
        description = "Main account for Raphael";
        useDefaultShell = true;
        extraGroups = [
          "networkmanager"
          "dialout"
          "plugdev"
          "wheel"
          "docker"
          "video"
        ];
        packages = with pkgs; [
          home-manager
        ];
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
    settings = {
      download-buffer-size = 268435456;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      auto-optimise-store = true;
    };
  };

  environment.variables.AGE_KEY_FILE = "/root/.config/age/keys.txt";
  programs = {
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    age
    bat
    cairo
    dconf
    fastfetch
    git
    home-manager
    lego
    libjpeg
    libpng
    libuuid
    linux-manual
    man
    man-pages
    man-pages-posix
    networkmanager
    openssl
    pkg-config
    postgresql
    protonup-ng
    python3
    python3Packages.pip
    qFlipper
    ripgrep
    swaylock
    swaylock-fancy
    tmux
    unzip
    vim
    wget
    wl-clipboard
    xclip
    xdg-desktop-portal-hyprland
    xsel
    yarn
    zsh
  ] ++ [
    inputs.agenix.packages.${pkgs.system}.agenix
  ];
}
