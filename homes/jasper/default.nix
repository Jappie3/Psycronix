{
  self,
  lib,
  pkgs,
  ...
}: let
  # cursor config
  current_cursor_package = pkgs.phinger-cursors;
  current_cursor_name_dark = "phinger-cursors-dark";
  current_cursor_name_light = "phinger-cursors-light";
  current_cursor_size = 24;
  # pkgs.phinger-cursors phinger-cursors phinger-cursors-light
  # pkgs.numix-cursor-theme Numix-Cursor Numix-Cursor-Light
  # get list of colors from files generated by PyWal (https://github.com/dylanaraps/pywal)
  colors_dark = (builtins.fromJSON (builtins.readFile ../../.theme/colors_dark.json)).colors;
  colors_light = (builtins.fromJSON (builtins.readFile ../../.theme/colors_light.json)).colors;
  # gtk theme
  gtk_package = pkgs.adw-gtk3;
  gtk_name_dark = "adw-gtk3-dark";
  gtk_name_light = "adw-gtk3";
  # qt theme
  qt_package = pkgs.adwaita-qt;
  qt_name_dark = "adwaita-dark";
  qt_name_light = "adwaita";
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
    qt_package = qt_package;
    qt_name = qt_name_dark;
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
    qt_package = qt_package;
    qt_name = qt_name_light;
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

    git = {
      enable = true;
      userName = "Jappie3";
      userEmail = "jasper22034@gmail.com";
      package = pkgs.gitFull;
      extraConfig = {
        # yes master cry about it
        init.defaultBranch = "master";
        # REuse REcorded REsolution
        rerere = {
          enabled = true;
          autoupdate = true;
        };
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
        user.signingkey = "~/.ssh/yubi-fido.pub";
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
    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";

    packages = [
      # switch the system theme
      (pkgs.writeShellScriptBin "switch-theme" ''
        set -e
        THEME_FILE="/tmp/theme"

        # we're changing the theme already, don't do anything
        [[ -e /tmp/LOAD_THEME_ACTIVATING ]] && exit 0
        # no theme set -> can't switch
        [[ ! -e $THEME_FILE ]] && exit 1

        # make sure we don't get stuck in a loop
        ${pkgs.coreutils}/bin/touch /tmp/LOAD_THEME_ACTIVATING
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
        # wait a little, activating a specialisation will also restart user services
        # and thus trigger load-theme.service, immediately overriding the switch we just did
        sleep .5
        ${pkgs.coreutils}/bin/rm /tmp/LOAD_THEME_ACTIVATING
      '')
    ];
  };

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = true;
  };
}
