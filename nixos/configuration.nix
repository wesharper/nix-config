{
  inputs,
  lib,
  config,
  pkgs,
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
    # You can add overlays here
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
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    cpu = {
      amd.updateMicrocode = true;
    };

    graphics = {
      enable = true;
      # extraPackages = with pkgs; [
      #   rocm-opencl-icd
      #   rocm-opencl-runtime
      #   amdvlk
      # ];
      # extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    };
  };

  boot.kernelModules = [
    "kvm-amd"
    "r8169"
    "k10temp"
  ];

  # For better CPU performance
  boot.kernelParams = [
    "amd_pstate=active" # Better CPU frequency scaling
    "processor.max_cstate=5" # Recommended for X3D CPUs
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.extraModulePackages = with config.boot.kernelPackages; [ pkgs.linuxPackages_hardened.r8125 ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Enable game mode
  # programs.gamemode.enable = true;

  # Better power management
  # services.thermald.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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
    kitty
    lm_sensors
    mangohud
    nixfmt-rfc-style
    spotify
    starship
    stow
    unzip
    vscode
    pkgs.linuxKernel.packages.linux_zen.zenpower
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  programs.zsh.enable = true;
  programs.steam = {
    enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
