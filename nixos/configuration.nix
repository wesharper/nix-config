{
  config,
  pkgs,
  ghostty,
  ...
}:
{
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

    ];
    config = {
      allowUnfree = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 42;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware = {
    # razer peripheral setup
    openrazer = {
      enable = true;
      users = [ "chuffed" ];
    };

    enableAllFirmware = true;

    graphics = {
      enable = true;
    };

    bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_testing;

  services.udev = {
    enable = true;
    extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    '';
  };

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;

    desktopManager = {
      # xterm.enable = false;
      gnome.enable = true;
    };

    displayManager = {
      gdm.enable = true;
      # defaultSession = "none+i3";
    };

    # windowManager.i3 = {
    #   enable = true;
    #   extraPackages = with pkgs; [
    #     dmenu # application launcher most people use
    #     i3status # gives you the default i3 status bar
    #     i3lock # default i3 screen locker
    #   ];
    # };

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  environment.gnome.excludePackages = with pkgs; [
    atomix
    epiphany
    evince
    geary
    iagno
    hitori
    gnome-user-docs
    gnome-bluetooth
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-maps
    gnome-music
    gnome-weather
    gnome-connections
    gnome-tour
    orca
    simple-scan
    snapshot
    tali
    totem
    yelp
    xterm
  ];

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  users.users.nm-openconnect = {
    isSystemUser = true;
    group = "networkmanager";
  };

  users.users.chuffed = {
    isNormalUser = true;
    description = "Weston Harper";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    _1password-gui
    brave
    direnv
    discord
    docker
    fzf
    gamescope
    (ghostty.packages.${system}.default)
    git
    git-credential-manager
    legendary-gl
    # lxappearance # i3wm appearance manager
    mailspring
    mangohud
    nixd
    nixfmt-rfc-style
    openrazer-daemon
    polychromatic
    slack
    spotify
    starship
    stow
    unzip
    vscode
    vulkan-tools
    winetricks
    wineWowPackages.stable
    zed-editor
    zoom-us
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      zed = "zeditor";
    };
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode = {
    enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
