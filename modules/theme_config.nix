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
  };
  config = mkIf config.theme.enable {
    home = {
      packages = [];
      sessionVariables.XCURSOR_THEME = config.theme.cursor_name;
      pointerCursor = {
        package = config.theme.cursor_package;
        name = config.theme.cursor_name;
        size = config.theme.cursor_size;
        gtk.enable = true;
      };
    };
    gtk = {
      enable = true;
      # TODO theme.package & theme.name
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
      platformTheme = "gtk";
      # TODO style.package & style.name
    };
  };
}
