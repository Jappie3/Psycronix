{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  # implement Secure Boot using Lanzaboote
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];
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
}
