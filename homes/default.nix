{
  config,
  inputs,
  pkgs,
  self,
  lib,
  ...
}: {
  home-manager = {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "old";
    extraSpecialArgs = {inherit inputs self;};
    users.jasper = import ./jasper;
  };
}
