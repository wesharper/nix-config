{
  config,
  pkgs,
  ...
}:
let
  r8125-source = pkgs.stdenv.mkDerivation {
    name = "r8125";
    version = "9.014.01";

    src = pkgs.fetchurl {
      url = "https://github.com/awesometic/realtek-r8125-dkms/archive/refs/tags/9.014.01-1.tar.gz";
      sha256 = "sha256-slCQRoNlTSuN/SdfsB4Xg2OlRlWGzH7sf9EOuQdXprM=";
    };

    makeFlags = [
      "KERNELDIR=${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build"
      "INSTALL_MOD_PATH=$(out)"
    ];

    installPhase = ''
      mkdir -p $out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/kernel/drivers/net/ethernet/realtek
      cp src/r8125.ko $out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/kernel/drivers/net/ethernet/realtek/
    '';
  };
in
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

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
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
    enableAllFirmware = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vulkan-tools
        libdecor
        gtk3
        gtk4
      ];
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

  systemd.services.bluetooth = {
    serviceConfig = {
      ConfigurationDirectoryMode = "0755";
    };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    r8125-source
  ];

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

  services.flatpak = {
    enable = true;

    packages = [ ];

    update.auto = {
      enable = true;
      onCalendar = "daily";
    };
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    geary
    gnome-user-docs
    epiphany
    gnome-bluetooth
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-maps
    gnome-music
    gnome-weather
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
    ];
  };

  environment.systemPackages = with pkgs; [
    _1password-gui
    brave
    discord
    fzf
    git
    git-credential-manager
    heroic
    kitty
    mailspring
    nixd
    nixfmt-rfc-style
    pciutils
    slack
    spotify
    starship
    stow
    unzip
    usbutils
    vscode
    vulkan-tools
    winetricks
    wineWowPackages.stable
    zed-editor
    zoom-us
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      zed = "zeditor";
    };
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          gamescope
          mangohud
        ];
    };
  };

  users.defaultUserShell = pkgs.zsh;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
