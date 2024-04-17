{
  self,
  lib,
  pkgs,
  ...
}: let
  # cursor config
  current_cursor_package = pkgs.phinger-cursors;
  current_cursor_name_dark = "phinger-cursors";
  current_cursor_name_light = "phinger-cursors-light";
  current_cursor_size = 20;
  # pkgs.phinger-cursors phinger-cursors phinger-cursors-light
  # pkgs.numix-cursor-theme Numix-Cursor Numix-Cursor-Light
  # get list of colors from files generated by PyWal (https://github.com/dylanaraps/pywal)
  colors_dark = (builtins.fromJSON (builtins.readFile ../../.theme/colors_dark.json)).colors;
  colors_light = (builtins.fromJSON (builtins.readFile ../../.theme/colors_light.json)).colors;
  # gtk theme
  gtk_package = pkgs.adw-gtk3;
  gtk_name_dark = "adw-gtk3-dark";
  gtk_name_light = "adw-gtk3";
  # border radius stuff
  border_radius = 12;
  window_outer_gap = 6;
  window_inner_gap = 2;
in let
  darkConfig = {
    enable = true;
    variant = "dark";
    gtk_package = gtk_package;
    gtk_name = gtk_name_dark;
    cursor_package = current_cursor_package;
    cursor_name = current_cursor_name_dark;
    cursor_size = current_cursor_size;
    colors = colors_dark;
    border_radius = border_radius;
    window_outer_gap = window_outer_gap;
    window_inner_gap = window_inner_gap;
  };
  lightConfig = {
    enable = true;
    variant = "light";
    gtk_package = gtk_package;
    gtk_name = gtk_name_light;
    cursor_package = current_cursor_package;
    cursor_name = current_cursor_name_light;
    cursor_size = current_cursor_size;
    colors = colors_light;
    border_radius = border_radius;
    window_outer_gap = window_outer_gap;
    window_inner_gap = window_inner_gap;
  };
in {
  imports = [
    ./xdg.nix
    ./services.nix
    ./graphical
    ./programs
    self.homeManagerModules.theme_config
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
        # REuse REcorded REsolution
        rerere.enabled = true;
        # git maintenance
        maintenance = {
          auto = false;
          strategy = "incremental";
        };
        # saves me some typing
        push.autoSetupRemote = true;
        # try to use columns
        column.ui = "auto";
        # don't sort alphabetically
        branch.sort = "committerdate";
        # sign commits cuz why not
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519.pub";
        url = {
          "https://git.kernel.org/".insteadOf = "kernel:";
          "git://git.kernel.org/".pushInsteadOf = "kernel:";
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

  # dark is default
  theme = darkConfig;

  specialisation = {
    # we use lib.mkForce to override the default values defined above
    dark.configuration.theme = lib.mkForce darkConfig;
    light.configuration.theme = lib.mkForce lightConfig;
  };

  home = {
    username = "jasper";
    homeDirectory = "/home/jasper";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";

    activation = {
      # https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
      reload-theme = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.systemd}/bin/systemctl --user start load-theme.service
      '';
    };

    packages = [
      # switch the system theme
      (pkgs.writeShellScriptBin "switch-theme" ''
        THEME_FILE="/tmp/theme"
        if [[ ! -e $THEME_FILE ]]; then
          # no theme set -> can't switch
          exit 1
        else
          # check what theme is set
          case "$(< "$THEME_FILE")" in
            "dark")
              # switch to light
              "$(${pkgs.ripgrep}/bin/rg ExecStart /run/current-system/etc/systemd/system/home-manager-jasper.service | ${pkgs.coreutils}/bin/cut -d ' ' -f 2)/specialisation/light/activate"
              ${pkgs.coreutils}/bin/echo "light" > "$THEME_FILE"
            ;;
            "light")
              # switch to dark
              "$(${pkgs.ripgrep}/bin/rg ExecStart /run/current-system/etc/systemd/system/home-manager-jasper.service | ${pkgs.coreutils}/bin/cut -d ' ' -f 2)/specialisation/dark/activate"
              ${pkgs.coreutils}/bin/echo "dark" > "$THEME_FILE"
            ;;
            *)
              exit 1
            ;;
          esac
        fi
      '')
    ];
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = true;
  };
}
