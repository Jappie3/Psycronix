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

  nixpkgs = {
    # add overlays
    #overlays = [
    #];

    # configure nixpkgs instance
    config = {
      # allow proprietary software
      allowUnfree = true;

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
    package = pkgs.nixUnstable;
    settings = {
      # enable flakes & nix command
      experimental-features = ["nix-command" "flakes"];
      # deduplicate & optimize nix store
      auto-optimise-store = true;
    };
  };

  boot = {
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
      #kernelModules = [];
      # kernel modules available in first stage (loaded when needed)
      availableKernelModules = [
        "btrfs"
        "dm_mod" # device mapper
        "nvme" # NVMe drives
        "xhci_pci" # USB 3.0 eXtensible Host Controller Interface
        "ehci_pci" # USB 2.0 Enhanced Host Controller Interface
        "usbhid" # USB Human Interface Device
        "usb_storage" # USB Mass Storage (USB flash drives)
        "ahci" # SATA devices on modern AHCI controllers
        #"uas" # USB attached SCSI drive
        #"sd_mod" # SCSI, SATA & PATA (IDI) devices
        #"sdhci_pci" # Secure Digital Host Controller Interface (SD cards)
        #"rtsx_pci_sdmmc" # Realtek PCI-E SD-MMC card host drive
      ];
      supportedFilesystems = [
        "btrfs"
        "ext4"
      ];
    };
    # kernel modules for second stage, see hardware-configuration.nix
    #kernelModules = [
    #  "kvm-amd"
    #];
    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    #kernelParams = [];
  };

  networking = {
    hostName = "Kainas";
    networkmanager.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  security = {
    polkit.enable = true;
    sudo.package = pkgs.sudo.override {withInsults = true;};
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
    thefuck.enable = true;
    less.enable = true;
  };

  xdg.portal.wlr.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  sound.enable = true;

  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
    opengl.enable = true;
    opengl.driSupport32Bit = true; # support for 32-bit programs (e.g. Wine)
    nvidia.modesetting.enable = true;
  };

  time.timeZone = "Europe/Brussels";

  services = {
    # OpenSSH daemon
    openssh.enable = true;
    # NTP
    ntp.enable = true;
    # Gnome keyring
    gnome.gnome-keyring.enable = true;
    # sound
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    # CUPS
    printing.enable = true;
    # bluetooth
    blueman.enable = true;
    # X
    xserver = {
      enable = false;
      displayManager.lightdm.enable = false;
      videoDrivers = ["nvidia" "amdgpu"];
      layout = "us";
      xkbVariant = "dvorak";
      # touchpad support
      libinput.enable = true;
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
    packages = with pkgs; [
      neofetch
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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

      XDG_SESSION_TYPE = "wayland";
    };

    systemPackages = with pkgs; [
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
      alejandra #nixpkgs-fmt
      man
      tldr
      pciutils
      lshw
      nvtop
      nvtop-amd
      acpi
      powertop
      power-profiles-daemon
      auto-cpufreq
      strace
      rsync
      tree
      pstree
      killall
      thefuck
      wev
      ydotool
      jq
      ripgrep
      socat
      imv
      feh
      grim
      slurp
      swappy
      mpv
      shared-mime-info
      playerctl
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
      kubectl
      k9s
      kubectx
      atool
      lynx
      bottom
      bandwhich

      # browsers
      firefox
      librewolf

      # programs
      #hyprland hyprland-protocols hyprland-share-picker xdg-desktop-portal-hyprland
      #linuxKernel.packages.linux_6_4.ddcci-driver # ddc/ci driver (control protocol for monitor settings)
      polkit
      polkit_gnome
      seatd
      pipewire
      brightnessctl
      thunderbird
      eww-wayland
      nerdfonts
      gnome.gucharmap
      pwvucontrol #pavucontrol
      wdisplays
      blueman
      tidal-hifi
      swww
      noisetorch
      dunst
      wlsunset
      rofi-wayland
      webcord-vencord
      signal-desktop
      obsidian
    ];

    # no default packages
    defaultPackages = [];
  };

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-symbols

      # normal fonts
      comic-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      roboto
      jost
      lexend

      # nerdfonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "RobotoMono" "NerdFontsSymbolsOnly"];})
    ];

    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Noto Color Emoji"];
      sansSerif = ["Noto Sans" "Noto Color Emoji"];
      monospace = ["Comic Mono" "JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
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
