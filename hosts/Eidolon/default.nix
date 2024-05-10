{
  self,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # nixos-anywhere <user>@<ip> --flake .#Eidolon

  imports = with self.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    sshd
    users
  ];

  users.jasper = {
    createUser = true;
    nixTrusted = true;
  };

  boot = {
    tmp.cleanOnBoot = true;
    consoleLogLevel = 0;
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_scsi"
      "virtio_blk"
    ];
    loader = {
      # use GRUB2 as the boot loader
      # no systemd-boot because Hetzner uses BIOS legacy boot
      grub = {
        enable = true;
        efiSupport = true;
        # disko will add devices with an EF02 partition
        #devices = [];
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  time.timeZone = "Europe/Oslo";

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      sandbox = true;
      keep-outputs = true;
      keep-derivations = true;
      log-lines = 25;
      warn-dirty = false;
    };
  };

  networking = {
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "dvorak";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [git tree];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
