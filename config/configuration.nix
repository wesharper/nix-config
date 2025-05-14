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

    ./gnome.nix
    # generated hardware config
    ./hardware-configuration.nix
  ];

  nixpkgs = {
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

    # additional drivers for xbox controllers
    xone.enable = true;

    graphics = {
      enable = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    amdgpu = {
      amdvlk.enable = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.udev = {
    enable = true;
    extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"

      # Xbox Elite 2 Over Bluetooth
      KERNEL=="hidraw*", KERNELS="*045e:0b22*", MODE="0660", TAG +="uaccess"
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

    excludePackages = with pkgs; [
      xterm
    ];

    desktopManager = {
      gnome.enable = true;
    };

    displayManager = {
      gdm.enable = true;
    };

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  environment.gnome.excludePackages = with pkgs; [
    atomix
    baobab
    epiphany
    evince
    geary
    gnome-bluetooth
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-connections
    gnome-console
    gnome-contacts
    gnome-disk-utility
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-software
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    gnome-weather
    hitori
    iagno
    loupe
    orca
    seahorse
    simple-scan
    snapshot
    tali
    totem
    yelp
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

  environment.systemPackages =
    with pkgs;
    [
      _1password-gui
      bottles
      brave
      cider
      clang # nvim
      clang-tools # nvim
      direnv
      discord
      docker
      fzf
      (ghostty.packages.${system}.default)
      git
      git-credential-manager
      gnumake # nvim
      heroic
      lazygit
      lutris
      magnetic-catppuccin-gtk
      mangohud
      neovim
      nixd
      nixfmt-rfc-style
      protonup-qt
      slack
      spotify
      spotify-player
      starship
      stow
      vscode
      wl-clipboard
      zoom-us
    ]
    ++ (with pkgs.gnomeExtensions; [
      pop-shell
      blur-my-shell
    ]);

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    google-fonts
  ];

  programs.zsh = {
    enable = true;
    autosuggestions = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
    ];
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
  system.stateVersion = "24.11";
}
