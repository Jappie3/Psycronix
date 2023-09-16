# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/32dd7cd3-ad98-4c55-be93-8fb10e348279";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["subvol=@nix"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["subvol=@log"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  # fileSystems."/home" =
  #   {
  #     device = "/dev/mapper/vg-home";
  #     fsType = "ext4";
  #   };

  # boot.initrd.luks.devices."home".device = "/dev/disk/by-uuid/b34c6a4a-5297-4efe-b93b-b3fe3c95ef4f";

  swapDevices = [
    {
      device = "/.swap/swapfile";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
