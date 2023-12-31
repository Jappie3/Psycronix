{
  self,
  pkgs,
  ...
}: let
  # cursor config
  current_cursor_package = pkgs.phinger-cursors;
  current_cursor_name_dark = "phinger-cursors";
  current_cursor_name_light = "phinger-cursors-light";
  current_cursor_size = 24;
  # pkgs.phinger-cursors phinger-cursors phinger-cursors-light
  # pkgs.numix-cursor-theme Numix-Cursor Numix-Cursor-Light
  # get list of colors from files generated by PyWal (https://github.com/dylanaraps/pywal)
  colors_dark = (builtins.fromJSON (builtins.readFile ../../.theme/colors_dark.json)).colors;
  colors_light = (builtins.fromJSON (builtins.readFile ../../.theme/colors_light.json)).colors;
in {
  imports = [
    ./xdg.nix
    ./graphical
    ./programs
    self.homeManagerModules.global_theme
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

  # default theme is dark
  theme = {
    cursor_package = current_cursor_package;
    cursor_name = current_cursor_name_dark;
    cursor_size = current_cursor_size;
    colors = colors_dark;
  };

  specialisation = {
    dark.configuration = {
      # config for dark theme
      theme = {
        cursor_package = current_cursor_package;
        cursor_name = current_cursor_name_dark;
        cursor_size = current_cursor_size;
        colors = colors_dark;
      };
    };
    light.configuration = {
      # config for light theme
      theme = {
        cursor_package = current_cursor_package;
        cursor_name = current_cursor_name_light;
        cursor_size = current_cursor_size;
        colors = colors_light;
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
}
