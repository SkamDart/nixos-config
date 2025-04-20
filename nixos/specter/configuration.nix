# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  # You can import other NixOS modules here
  imports = [
    ./hardware-configuration.nix
    # inputs.home-manager.nixosModules.home-manager
  ];

  # home-manager = {
  #   extraSpecialArgs = { inherit inputs outputs; };
  #   users = {
  #     stinky = import ../home-manager/home.nix;
  #   };
  # };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      # outputs.overlays.modifications
      # outputs.overlays.neovim-nightly-overlay
      # outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Join us now and share the software, you'll be free hackers, you'll be free.
      # Hoarders can get piles of money, that is true, hackers, that is true.
      # But they cannot help their neighbors; that's not good, hackers, that's not good.
      allowUnfree = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      # Enable flakes and new 'nix' command
      experimental-features = "flakes nix-command recursive-nix";
      # Deduplicate and optimize nix store
      substituters = [
        "https://cache.iog.io"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ "root" "specter" ];
    };
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    specter = {
      extraGroups = [ "dialout" "networkmanager" "wheel" ];
      isNormalUser = true;
      packages = with pkgs; [
        cachix
        curl
        emacs
        git
        ghostty
        neovim
        wget
      ];
      password = "$y$j9T$ouZrPY3X1AQ075U/FlxoJ1$eGch1Kp/V.S9JhWA4fVmbbfxgcb9UDFA3GrL0H1FKN3";
      shell = pkgs.fish;
    };
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      lightdm.enable = true;
      defaultSession = "none+i3";
    };

    libinput.enable = true;

    windowManager = {
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          dmenu
          i3lock
          i3lock-fancy
          i3status
          i3-gaps
          rofi
        ];
      };
    };
  };

  programs.fish.enable = true;

  services.udev.extraRules = ''
  # Copyright 2011,2015 Ettus Research LLC
  # Copyright 2018 Ettus Research, a National Instruments Company
  #
  # SPDX-License-Identifier: GPL-3.0-or-later
  #

  #USRP1
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="fffe", ATTRS{idProduct}=="0002", MODE:="0666"

  #B100
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0002", MODE:="0666"

  #B200
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0020", MODE:="0666"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0021", MODE:="0666"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0022", MODE:="0666"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3923", ATTRS{idProduct}=="7813", MODE:="0666"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3923", ATTRS{idProduct}=="7814", MODE:="0666"
  '';
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
