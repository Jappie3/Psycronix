{
  lib,
  config,
  ...
}:
with lib; {
  options.theme = {
    enable = mkEnableOption "Enable system-wide theme config";
    variant = mkOption {
      description = "Slug name, e.g. 'dark' or 'light'";
      type = types.str;
    };
    gtk_package = mkOption {
      description = "GTK package that supplies the global theme";
      type = types.package;
    };
    gtk_name = mkOption {
      description = "GTK theme that should be used";
      type = types.str;
    };
    qt_package = mkOption {
      description = "QT package that supplies the global theme";
      type = types.package;
    };
    qt_name = mkOption {
      description = "QT theme that should be used";
      type = types.str;
    };
    cursor_package = mkOption {
      description = "Cursor package that supplies the global theme";
      type = types.package;
    };
    cursor_name = mkOption {
      description = "Cursor theme that should be used";
      type = types.str;
    };
    cursor_size = mkOption {
      description = "Cursor size";
      default = 24;
      type = types.int;
    };
    colors = mkOption {
      description = "Attribute set containing 16 colours that will be used system-wide for a variety of things";
      type = types.attrs;
    };
    border_radius = mkOption {
      description = "Global option for setting the border radius of windows & other graphical elements";
      type = types.int;
      default = 12;
    };
    window_outer_gap = mkOption {
      description = "Defines gap between windows & the edge of the screen";
      type = types.int;
      default = 2;
    };
    window_inner_gap = mkOption {
      description = "Defines gap between windows";
      type = types.int;
      default = 2;
    };
  };
  config = mkIf config.theme.enable {
    home = {
      sessionVariables = {
        XCURSOR_THEME = config.theme.cursor_name;
        XCURSOR_SIZE = config.theme.cursor_size;
        HYPRCURSOR_THEME = config.theme.cursor_name;
        HYPRCURSOR_SIZE = builtins.toString config.theme.cursor_size;
      };
      pointerCursor = {
        package = config.theme.cursor_package;
        name = config.theme.cursor_name;
        size = config.theme.cursor_size;
        gtk.enable = true;
      };
    };
    gtk = {
      enable = true;
      cursorTheme = {
        name = config.theme.cursor_name;
        package = config.theme.cursor_package;
      };
      theme = {
        name = config.theme.gtk_name;
        package = config.theme.gtk_package;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style = {
        name = config.theme.qt_name;
        package = config.theme.qt_package;
      };
    };
  };
}
