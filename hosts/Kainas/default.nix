{
  self,
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = with self.nixosModules; [
    ./hardware-configuration.nix
    sshd
    users
    web-eid
    secure_boot
    cpu_amd
    laptop_power
  ];

  users.jasper = {
    createUser = true;
    nixTrusted = true;
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
      #cudaSupport = true;
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
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      # deduplicate nix store
      auto-optimise-store = true;
      # sandbox builds (default)
      sandbox = true;
      # more logs
      log-lines = 25;
      # no dirty git tree warning
      warn-dirty = false;
    };
    # keep intermediary dependencies (no re-download after a gc) & enable flakes
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    # flake registries for nixpkgs unstable & stable
    # used by e.g. nix shell nixpkgs#hello
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      stable.flake = inputs.stable;
    };
  };

  documentation = {
    enable = true;
    # NixOS' own documentation
    nixos.enable = true;
    # man pages
    man.enable = true;
    # info pages & info command
    info.enable = true;
    # documentation distributed in packages' /share/doc
    doc.enable = true;
    # documentation targeted at developers
    dev.enable = false;
  };

  boot = {
    # emulate aarch64
    binfmt.emulatedSystems = ["aarch64-linux"];
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
      systemd-boot = {
        enable = true;
        editor = false; # don't allow editing the kernel command-line before boot
        configurationLimit = 64; # prevent boot partition running out of disk space
        consoleMode = "max"; # resolution of console, max -> highest-numbered available mode
      };
      # whether installation process is allowed to modify EFI boot vars
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      luks = {
        yubikeySupport = true;
        reusePassphrases = true;
      };
      verbose = true;
      # kernel modules loaded in first stage
      # https://wiki.archlinux.org/title/Kernel_mode_setting#Early_KMS_start
      kernelModules = [
        "amdgpu"
      ];
      # kernel modules available in first stage (loaded when needed)
      availableKernelModules = [
        "nvme" # NVMe drives
        "xhci_pci" # USB 3.0 eXtensible Host Controller Interface
        "ehci_pci" # USB 2.0 Enhanced Host Controller Interface
        "usbhid" # USB Human Interface Device
        "usb_storage" # USB Mass Storage (USB flash drives)
        "ahci" # SATA devices on modern AHCI controllers
      ];
      supportedFilesystems = [
        "btrfs"
        "ext4"
      ];
    };
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    # disable dhcpcd & resolvconf
    dhcpcd.enable = false;
    resolvconf.enable = false;
    # use nftables instead of iptables
    nftables.enable = true;
    # [ip] [hostname]
    # extraHosts = ''
    # '';
    firewall = {
      allowedTCPPorts = [];
      enable = true;
    };
    nameservers = ["2620:fe::fe" "2620:fe::9" "9.9.9.9" "149.112.112.112"]; # Quad9
    wireless.iwd = {
      enable = true;
      settings = {
        # https://git.kernel.org/pub/scm/network/wireless/iwd.git/tree/src/iwd.network.rst
        # https://git.kernel.org/pub/scm/network/wireless/iwd.git/tree/src/iwd.config.rst
        Settings.AutoConnect = true;
        Network.EnableIPv6 = true;
        General = {
          ManagementFrameProtection = 1; # 0-> disabled, 1-> enabled (if hardware & AP support it), 2-> always required
          AddressRandomization = "network"; # MAC address is randomized on each connection to a network
          AddressRandomizationRange = "full"; # randomize all 6 octets
          RoamRetryInterval = 20; # how long iwd waits before attempting to roam again if last attempt failed, or if signal of new BSS is still considered weak
          RoamThreshold = -70; # how agressively iwd should roam when connected to a 2.4GHz AP (rssi dBm value, -100 to 1, default -70)
          RoamThreshold5G = -76; # how agressively iwd should roam when connected to a 5GHz AP (rssi dBm value, -100 to 1, default -76)
        };
        Scan = {
          DisablePeriodicScan = false;
          InitialPeriodicScanInterval = 2; # initial periodic scan interval upon disconnect
          MaximumPeriodicScanInterval = 300; # maximum periodic scan interval
          DisableRoamingScan = false;
        };
      };
    };
  };
  services.resolved = {
    enable = true;
    domains = ["~."]; # don't use per-link DNS servers if they set "domains=~.", only use them if more specific search domains match
    fallbackDns = ["1.1.1.1#cloudflare-dns.com" "8.8.8.8#dns.google" "1.0.0.1#cloudflare-dns.com" "8.8.4.4#dns.google" "2606:4700:4700::1111#cloudflare-dns.com" "2001:4860:4860::8888#dns.google" "2606:4700:4700::1001#cloudflare-dns.com" "2001:4860:4860::8844#dns.google"];
    dnssec = "false"; # validate DNS lookups using DNSSEC - recommended to disable this for now, too many non-compliant servers in the wild
    dnsovertls = "true"; # encrypt DNS lookups using TLS
    llmnr = "true"; # link-local multicast name resolution (RFC 4795)
  };
  systemd = {
    network = {
      enable = true;
      # https://www.freedesktop.org/software/systemd/man/latest/networkd.conf.html
      config = {};
      # https://www.freedesktop.org/software/systemd/man/latest/systemd.network.html
      networks = {
        "20-lan" = {
          matchConfig.Type = "ether"; # wired interfaces
          networkConfig = {
            DHCP = "yes";
            DNSDefaultRoute = false; # don't use this link's DNS servers for domains that do not match any link's configured Domains= setting, only use them for resolving names that match at least one of the domains configured on this link
            IPv6PrivacyExtensions = true; # RFC 4941: Privacy Extensions for Stateless Address Autoconfiguration in IPv6
            IPv6AcceptRA = true; # Router Advertisement (RA) reception support
            # IPForward = "yes";
            # IPMasquerade = "no";
          };
        };
        "30-wan" = {
          matchConfig.Type = "wlan"; # wireless interfaces
          networkConfig = {
            DHCP = "yes";
            DNSDefaultRoute = false; # don't use this link's DNS servers for domains that do not match any link's configured Domains= setting, only use them for resolving names that match at least one of the domains configured on this link
            IPv6PrivacyExtensions = true; # RFC 4941: Privacy Extensions for Stateless Address Autoconfiguration in IPv6
            IPv6AcceptRA = true; # Router Advertisement (RA) reception support
          };
        };
      };
    };
  };

  security = {
    polkit.enable = true;
    # RealtimeKit system service, hands out realtime scheduling priority to user processes on demand
    rtkit.enable = true;
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
      LC_TIME = "de_DE.UTF-8";
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
    dconf.enable = true; # virt-manager requires dconf to remember settings
    virt-manager.enable = true;
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
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
      # don't set SSH_ASKPASS (just prompt in terminal)
      enableAskPassword = false;
      # automatically add ssh key to agent
      extraConfig = ''
        Host *
          IdentityFile      ~/.ssh/yubi-fido
          IdentityFile      ~/.ssh/id_ed25519
          AddKeysToAgent    yes
      '';
    };
    steam = {
      # TODO: env var for STEAM_EXTRA_COMPAT_TOOLS_PATHS ?
      enable = true;
      # Steam Remote Play & Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
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
    enableRedistributableFirmware = true;
    # support for e.g. Steam Controller
    steam-hardware.enable = true;
    pulseaudio.enable = false;
    bluetooth = {
      enable = true;
      powerOnBoot = false; # sets [Policy] AutoEnable=false in main.conf
      package = pkgs.bluez5-experimental;
      # see https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/src/main.conf for the default config file w/ comments
      disabledPlugins = ["nfc" "sap" "health" "midi"];
      settings = {
        General = {
          # set device class to computer
          Class = "0x000100";
          # both BR/EDR & LE enabled if supported by hw (default)
          ControllerMode = "dual";
          # always accept JUST-WORKS repairing requests (pairing without entering keys)
          JustWorksRepairing = "always";
          # Multi Profile Specification support (device can operate under multiple Bluetooth profiles simultaneously)
          MultiProfile = "multiple";
          # enable D-Bus experimental interfaces
          Experimental = true;
        };
      };
    };
    opengl = {
      enable = true;
      driSupport = true;
      # support for 32-bit programs (e.g. Wine)
      driSupport32Bit = true;
    };
    # https://wiki.nixos.org/wiki/Nvidia
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
    logind.extraConfig = ''
      RuntimeDirectorySize=8G
    '';
    # daemon that allows updating firmware
    # fwupdmgr [refresh | get-devices | get-updates | update]
    fwupd.enable = true;
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
      # pw-config -> see all loaded config files
      # see https://docs.pipewire.org/page_module_combine_stream.html & https://wiki.nixos.org/w/index.php?title=PipeWire
      extraConfig.pipewire."10-virt-sink" = {
        "context.modules" = [
          {
            name = "libpipewire-module-combine-stream";
            args = {
              "combine.mode" = "sink";
              "node.name" = "combine_sink";
              "node.description" = "Combined sink";
              "combine.latency-compensate" = false;
              "combine.props" = {
                "audio.position" = ["FL" "FR"];
              };
              "stream.rules" = [
                {
                  "matches" = [{"media.class" = "Audio/Sink";}];
                  "actions" = {
                    "create-stream" = {
                      "combine.audio.position" = ["FL" "FR"];
                      "audio.position" = ["FL" "FR"];
                    };
                  };
                }
              ];
            };
          }
        ];
      };
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
      xkb = {
        layout = "us";
        variant = "dvorak";
      };
    };
    # touchpad support
    libinput.enable = true;
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
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

  environment = {
    # env vars set by PAM early in login process
    # values may not contain the " character
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";

      # pager
      PAGER = "less -FR";
      SYSTEMD_PAGERSECURE = "true";

      # fuck electron
      NIXOS_OZONE_WL = "1";

      # XDG
      XDG_SESSION_TYPE = "wayland";

      # very important
      ANSIBLE_COW_SELECTION = "random";

      # NH
      FLAKE = "$HOME/.config/psycronix";

      # nixos-rebuild w/ --use-remote-sudo -> needs TTY, can be forced with -tt SSH options
      NIX_SSHOPTS = "-tt";
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
      inputs.zotero-nix.packages.${system}.default # Zotero with a recent Firefox version

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

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
