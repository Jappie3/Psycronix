{lib, ...}: let
  inherit (lib) mkOption mdDoc types;
in {
  options.theme = mkOption {
    type = types.attrs;
    default = {};
    description = mdDoc ''
      Home-manager module to configure the theme of the system, e.g. colors, cursor theme, etc.
    '';
  };
}
