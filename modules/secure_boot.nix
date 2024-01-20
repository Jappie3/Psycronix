{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];
  options.secure_boot.enable = mkEnableOption "Enable Secure Boot using Lanzaboote";
  config = mkIf config.secure_boot.enable {
    environment.systemPackages = [pkgs.sbctl];
    boot = {
      # see https://github.com/NixOS/rfcs/blob/master/rfcs/0125-bootspec.md
      bootspec.enable = true;

      # https://github.com/nix-community/lanzaboote
      lanzaboote = {
        enable = true;
        # sudo sbctl create-keys -> creates keys in /etc/secureboot
        pkiBundle = "/etc/secureboot";
      };

      loader = {
        # systemd-boot UEFI
        efi.canTouchEfiVariables = true;
        # lanzaboote replaces the systemd-boot module
        systemd-boot.enable = lib.mkForce false;
      };
    };
  };
}
