{
  self,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    self.nixosModules.sshd
  ];

  sdImage.compressImage = false;

  boot.loader = {
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  time.timeZone = "Europe/Oslo";

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    settings = {
      trusted-users = ["jasper"];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };

  networking = {
    hostName = "NixOS-image";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "dvorak";
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    users.jasper = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1mAN5Db7eZ0iuBGGxdPqQCR2l6jDZBjgX4ZVOcip27 jasper@Kainas"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment = {
    systemPackages = with pkgs; [
      git
      tree
      vim
      ripgrep
    ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
