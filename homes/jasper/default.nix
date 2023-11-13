{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./xdg.nix
    ./graphical
    ./programs
  ];

  programs = {
    # let Home Manager manage itself when in standalone mode
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "Jappie3";
      userEmail = "jasper22034@gmail.com";
      package = pkgs.gitFull;
      extraConfig = {
        # yes master cry about it
        init.defaultBranch = "master";
        url = {
          "https://github.com/".insteadOf = "github:";
          "ssh://git@github.com/".pushInsteadOf = "github:";
          "https://gitlab.com/".insteadOf = "gitlab:";
          "ssh://git@gitlab.com/".pushInsteadOf = "gitlab:";
          "https://aur.archlinux.org/".insteadOf = "aur:";
          "ssh://aur@aur.archlinux.org/".pushInsteadOf = "aur:";
          "https://git.sr.ht/".insteadOf = "srht:";
          "ssh://git@git.sr.ht/".pushInsteadOf = "srht:";
          "https://codeberg.org/".insteadOf = "codeberg:";
          "ssh://git@codeberg.org/".pushInsteadOf = "codeberg:";
        };
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home = {
    username = "jasper";
    homeDirectory = "/home/jasper";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";

    packages = with pkgs; [
      inputs.ags.packages.${pkgs.system}.default
      # inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
      inputs.shadower.packages.${pkgs.system}.shadower
      inputs.nh.packages.${pkgs.system}.default
    ];
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = true;
  };
}
