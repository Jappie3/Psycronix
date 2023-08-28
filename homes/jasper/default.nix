{ 
  config, 
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # inputs.hyprland.homeManagerModules.default
    inputs.neovim-flake.homeManagerModules.default
    ./graphical
  ];

  config = {

    programs = {
      # let Home Manager manage itself when in standalone mode
      home-manager.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    home = {
      username = "jasper";
      homeDirectory = "/home/jasper";
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
    };

    manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = true;
    };

  };
}
