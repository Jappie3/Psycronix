{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];
  config.programs.ags = {
    enable = true;
    configDir = ./ags-config;
  };
}
