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

      git = {
        enable = true;
        userName = "Jappie3";
        userEmail = "jasper22034@gmail.com";
	package = pkgs.gitFull;
	extraConfig = {
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
