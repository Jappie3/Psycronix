{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # enable some modules
  web-eid.enable = true;
  secure_boot.enable = true;

  nixpkgs = {
    # add overlays
    #overlays = [
    #];

    hostPlatform = "x86_64-linux";

    # configure nixpkgs instance
    config = {
      # allow proprietary software
      allowUnfree = true;
      # cuda support
      #cudaSupport = true;

      # enable nix-helper
      nh = {
        enable = true;
        clean = {
          enable = true;
          dates = "daily";
        };
      };
    };
  };

  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://anyrun.cachix.org"
        "https://viperml.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="
      ];
      # enable flakes & nix command
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = ["jasper"];
      # deduplicate & optimize nix store
      auto-optimise-store = true;
      # sandbox builds (default)
      sandbox = true;
      # keep build-time dependencies
      keep-outputs = true;
      keep-derivations = true;
      # more logs
      log-lines = 25;
      # no dirty git tree warning
      warn-dirty = false;
    };
  };

  documentation = {
    enable = true;
    nixos = {
      # NixOS' own documentation
      enable = true;
      includeAllModules = true;
      options.splitBuild = true;
    };
    man = {
      enable = true;
      # whether to generate manual page index caches
      generateCaches = false;
      # use man-db (default)
      man-db.enable = true;
    };
    # info pages & info command
    info.enable = true;
    # documentation distributed in packages' /share/doc
    doc.enable = true;
    # documentation targeted at developers
    dev.enable = false;
  };

  boot = {
    # clean /tmp on boot because I fill it with random crap
    tmp.cleanOnBoot = true;
    # kernel console loglevel
    consoleLogLevel = 0;
    # which kernel to use
    #kernelPackages = ;
    # shared between all bootloaders
    loader = {
      # hold space to show boot menu
      timeout = 0;
      # whether to copy necessary boot files to /boot (/nix/store is not needed by boot loader)
      generationsDir.copyKernels = true;
      # whether to enable the systemd-boot EFI boot manager
      systemd-boot.enable = true;
      # whether installation process is allowed to modify EFI boot vars
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      luks = {
        yubikeySupport = true;
        reusePassphrases = true;
      };
      verbose = true;
      # always loaded in first stage
      # https://wiki.archlinux.org/title/Kernel_mode_setting#Early_KMS_start
      # kernelModules = [
      #   "amdgpu"
      # ];
      # kernel modules available in first stage (loaded when needed)
      availableKernelModules = [
        "btrfs" # butter filesystem
        "dm_mod" # device mapper
        "nvme" # NVMe drives
        "xhci_pci" # USB 3.0 eXtensible Host Controller Interface
        "ehci_pci" # USB 2.0 Enhanced Host Controller Interface
        "usbhid" # USB Human Interface Device
        "usb_storage" # USB Mass Storage (USB flash drives)
        "ahci" # SATA devices on modern AHCI controllers
        "sd_mod" # SCSI, SATA & PATA (IDI) devices
        #"uas" # USB attached SCSI drive
        #"sdhci_pci" # Secure Digital Host Controller Interface (SD cards)
        #"rtsx_pci_sdmmc" # Realtek PCI-E SD-MMC card host drive
      ];
      supportedFilesystems = [
        "btrfs"
        "ext4"
      ];
    };
    # kernel modules for second stage, see hardware-configuration.nix
    kernelModules = [
      # load AMD KVM kernel module, see https://wiki.archlinux.org/title/KVM
      "kvm-amd"
    ];
    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    #kernelParams = [];
  };

  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  security = {
    polkit.enable = true;
    # RealtimeKit system service, hands out realtime scheduling priority to user processes on demand
    rtkit.enable = true;
    sudo.package = pkgs.sudo.override {withInsults = true;};
    # https://github.com/NixOS/nixpkgs/issues/158025
    pam.services.swaylock = {};
  };

  i18n = {
    # I hate glibc
    # https://www.localeplanet.com/icu/en-150/index.html
    # https://sourceware.org/bugzilla/show_bug.cgi?id=22473
    # defaultLocale = "en_150.UTF-8/UTF-8";
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      # Europe - English
      #"en_150.UTF-8/UTF-8"
      # US - English
      "en_US.UTF-8/UTF-8"
      # no stupid measurements or dates
      "en_IE.UTF-8/UTF-8"
      "en_DK.UTF-8/UTF-8"
    ];
    # https://sourceware.org/glibc/wiki/Locales
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      # interpretation of sequences of bytes of text data characters, classification of characters, etc.
      LC_CTYPE = "en_US.UTF-8";
      # collation rules
      LC_COLLATE = "en_IE.UTF-8";
      # affirmative & negative responses for messages and menus
      LC_MESSAGES = "en_IE.UTF-8";
      # monetary-related formatting
      LC_MONETARY = "en_IE.UTF-8"; #"en_US.UTF-8/UTF-8@euro";
      # nonmonetary numeric formatting
      LC_NUMERIC = "en_IE.UTF-8";
      # date & time formatting
      LC_TIME = "en_IE.UTF-8";
      # not set here: paper, name, address, telephone, measurement, identification
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "dvorak"; #"us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  programs = {
    hyprland.enable = true;
    noisetorch.enable = true;
    thefuck.enable = true;
    less.enable = true;
    ssh = {
      # start OpenSSH agent upon login
      startAgent = true;
      # find these with `ssh-keyscan <hostname>`
      knownHosts = {
        github-ed25519.hostNames = ["github.com"];
        github-ed25519.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        gitlab-ed25519.hostNames = ["gitlab.com"];
        gitlab-ed25519.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
        codeberg-ed25519.hostNames = ["codeberg.org"];
        codeberg-ed25519.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
      };
    };
    steam = {
      # TODO: env var for STEAM_EXTRA_COMPAT_TOOLS_PATHS ?
      enable = true;
      # Steam Remote Play & Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware = {
    # support for e.g. Steam Controller
    steam-hardware.enable = true;
    pulseaudio.enable = false;
    bluetooth.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      # support for 32-bit programs (e.g. Wine)
      driSupport32Bit = true;
    };
    # https://nixos.wiki/wiki/Nvidia
    nvidia = {
      #package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      # use the Nvidia open source kernel module
      open = true;
      # enable Nvidia settings menu, see nvidia-settings
      nvidiaSettings = true;
      # enable kernel modesetting
      modesetting.enable = true;
      powerManagement = {
        # experimental power management through systemd, can cause sleep/suspend to fail
        enable = false;
        # experimental power management, turns off GPU when not in use (Turing or newer)
        finegrained = false;
      };
      # offloading to dGPU
      prime = {
        # enable PRIME offloading
        offload.enable = true;
        # lspci | grep VGA | grep 'Advanced Micro Devices' -> 06:00.0
        amdgpuBusId = "PCI:6:0:0";
        # lspci | grep VGA | grep 'NVIDIA' -> 01:00.0
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  time.timeZone = "Europe/Brussels";

  services = {
    # OpenSSH daemon
    openssh = {
      enable = true;
      # systemd will start an SSHD instance for each incoming connection
      startWhenNeeded = true;
      # port on which SSH daemon listens
      ports = [22];
      # automatically open firewall
      openFirewall = true;
      # City of Tears
      banner = "\n\tThe great gates have been sealed.\n\t\tNone shall enter.\n\t\tNone shall leave.\n\n\n";
      # some security stuff
      settings = {
        X11Forwarding = false;
        UseDns = false;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        # key exchange algorithms recommended by nixpkgs#ssh-audit
        # see https://github.com/numtide/srvos/blob/main/nixos/common/openssh.nix
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
        ];
      };
    };
    # NTP
    ntp.enable = true;
    # Gnome keyring
    gnome.gnome-keyring.enable = true;
    # Profile Sync Daemon (browser profiles)
    psd = {
      enable = true;
      resyncTimer = "10m";
    };
    # sound
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    # D-Bus thumbnailer service
    tumbler.enable = true;
    # CUPS
    printing.enable = true;
    # bluetooth
    blueman.enable = true;
    # X
    xserver = {
      enable = true;
      displayManager.lightdm.enable = false;
      videoDrivers = ["nvidia"]; #"amdgpu"];
      layout = "us";
      xkbVariant = "dvorak";
      # touchpad support
      libinput.enable = true;
    };
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
    # DBus daemon, allows changing system behavior based on user-selected power profiles
    power-profiles-daemon.enable = true;
    # automatic CPU speed & power optimizer
    auto-cpufreq = {
      enable = true;
      settings = {
        # list of governors: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
        # frequencies are in MHz
        battery = {
          governor = "schedutil";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
    # DBus service that provides power management support to applications.
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 8;
      percentageAction = 6;
      # PowerOff, Hibernate, HybridSleep
      criticalPowerAction = "Hibernate";
    };
  };

  systemd = {
    services.NetworkManager-wait-online.enable = false;
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  users.users.jasper = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    # don't set this when using NixOps
    openssh.authorizedKeys.keys = [
      # my own public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1mAN5Db7eZ0iuBGGxdPqQCR2l6jDZBjgX4ZVOcip27 jasper@Kainas"
    ];
    packages = with pkgs; [
      neofetch
    ];
  };

  environment = {
    # global variables
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";

      # SSH
      SSH_AUTH_SOCK = "/run/user/\${UID}/keyring/ssh";

      # pager
      PAGER = "less -FR";
      SYSTEMD_PAGERSECURE = "true";

      # Wayland specific
      #
      WLR_NO_HARDWARE_CURSORS = "1";
      XCURSOR_SIZE = "24";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      #
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      #
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      #
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      EGL_PLATFORM = "wayland";

      # fuck electron
      NIXOS_OZONE_WL = "1";

      # XDG
      XDG_SESSION_TYPE = "wayland";

      # NH
      FLAKE = "$HOME/.config/psycronix";
    };

    systemPackages = with pkgs; let
      nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '';
    in [
      inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere # NixOS-anywhere
      inputs.agenix.packages.${pkgs.system}.agenix # Agenix
      inputs.nh.packages.${pkgs.system}.default # Nix CLI helper
      inputs.ags.packages.${pkgs.system}.default # Aylur's GTK shell
      inputs.shadower.packages.${pkgs.system}.shadower # CLI utility to add rounded borders, padding & shadow to images
      inputs.nix-gaming.packages.${pkgs.system}.proton-ge # Custom build of Proton with the most recent bleeding-edge Proton Experimental WINE

      # run 'nvidia-offload someProgram' to run it on dGPU
      nvidia-offload

      # drivers
      mesa
      nvidia-vaapi-driver
      libva
      libva-utils

      # editors
      vim
      neovim
      vscodium

      # terminals
      alacritty
      kitty

      # cli
      curl
      wget
      less
      git
      alejandra
      # install NixOS anywhere
      inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
      man
      tldr
      file
      pciutils
      lshw
      nvtop
      nvtop-amd
      cudatoolkit
      sysstat
      acpi
      powertop
      power-profiles-daemon
      auto-cpufreq
      strace
      rsync
      tree
      trash-cli # cli to freedesktop.org trashcan
      pstree
      killall
      thefuck
      wev
      wlr-randr
      ydotool
      jq
      ripgrep
      socat
      imv
      feh
      zathura
      grim
      slurp
      swappy
      gimp
      mpv
      shared-mime-info
      playerctl
      pulseaudio
      pamixer
      wl-clipboard
      wf-recorder
      ffmpeg
      neofetch
      cava
      sl
      cowsay
      lolcat
      wayvnc
      testssl
      mtr
      dig
      nmap
      whois
      ansible
      kubectl
      k9s
      kubectx
      atool
      bottom
      bandwhich
      sassc

      # browsers
      nyxt
      firefox
      librewolf
      lynx
      tor
      tor-browser-bundle-bin

      # programs
      #hyprland hyprland-protocols hyprland-share-picker xdg-desktop-portal-hyprland
      #linuxKernel.packages.linux_6_4.ddcci-driver # ddc/ci driver (control protocol for monitor settings)
      polkit
      polkit_gnome
      seatd
      pipewire
      brightnessctl
      thunderbird
      obs-studio
      eww-wayland
      gnome.gucharmap
      pwvucontrol
      pavucontrol
      wdisplays
      # for e.g. wlroots-idle-inhibit
      wlroots.examples
      # automatically lock screen
      swayidle
      blueman
      tidal-hifi
      swww
      swaylock-effects
      noisetorch
      dunst
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      wlsunset
      starship # customizable shell prompt
      signal-desktop
      obsidian
      steam

    ];

    # no default packages
    defaultPackages = [];
  };

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-symbols
      material-icons
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      comic-mono
      roboto
      jost
      lexend
      inter

      # nerdfonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
          "RobotoMono"
          "NerdFontsSymbolsOnly"
        ];
      })
    ];

    fontDir = {
      # create directory with links to all fonts:
      # /run/current-system/sw/share/X11/fonts
      enable = true;
      decompressFonts = true;
    };

    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;

    # user defined fonts
    fontconfig = {
      enable = true;
      defaultFonts = {
        # placing "Noto Serif" first fixes weird spacing in firefox
        serif = ["Noto Serif" "Roboto Serif" "Noto Color Emoji"];
        sansSerif = ["Inter" "Lexend" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Symbols Nerd Font" "Material Symbols Rounded" "Noto Color Emoji" "FireCode Nerd Font"];
      };
    };
  };

  # create a file /etc/current-system-packages that lists all installed packages
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
