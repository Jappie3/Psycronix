{
  self,
  lib,
  ...
}: let
  inherit (self) inputs; #self = inputs.self;

  homes = import ../homes;

  # flake inputs
  home-manager = inputs.home-manager.nixosModules.home-manager;
  agenix = inputs.agenix.nixosModules.default;
  disko = inputs.disko.nixosModules.disko;

  # extraSpecialArgs that all hosts need
  sharedArgs = {inherit self lib inputs;};
in {
  flake.nixosConfigurations = {
    Kainas = lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = sharedArgs;
      modules =
        [
          {networking.hostName = "Kainas";}
          ./Kainas
        ]
        ++ [
          home-manager
          homes
          agenix
        ];
    };
  };
}
