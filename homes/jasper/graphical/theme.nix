{config, ...}: let
  cursor_package = config.theme.cursor_package;
  cursor_name = config.theme.cursor_name;
in {
  home = {
    sessionVariables.XCURSOR_THEME = cursor_name;
    pointerCursor = {
      package = cursor_package;
      name = cursor_name;
      size = 24;
      gtk.enable = true;
    };
  };
  gtk = {
    enable = true;
    # TODO theme.package & theme.name
    cursorTheme = {
      name = cursor_name;
      package = cursor_package;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    # TODO style.package & style.name
  };
}
