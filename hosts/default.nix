{
  self,
  lib,
  ...
}: let
  inherit (self) inputs;

  homes = import ../homes;

  # flake inputs
  home-manager = inputs.home-manager.nixosModules.home-manager;
  agenix = inputs.agenix.nixosModules.default;
  agenix-rekey = inputs.agenix-rekey.nixosModules.default;
  secret_config = self.nixosModules.secret_config;
  disko = inputs.disko.nixosModules.disko;

  secretModules = [
    agenix
    agenix-rekey
    secret_config
  ];

  # args shared across hosts
  sharedArgs = {inherit self lib inputs;};
in {
  Kainas = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = sharedArgs;
    modules =
      [
        {networking.hostName = "Kainas";}
        ./Kainas
        home-manager
        homes
      ]
      ++ secretModules;
  };
  Eidolon_x86_64 = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = sharedArgs;
    modules = [
      {networking.hostName = "Eidolon";}
      ./Eidolon_x86_64
      disko
    ];
  };
  Eidolon_aarch64 = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = sharedArgs;
    modules = [
      {networking.hostName = "Eidolon";}
      ./Eidolon_aarch64
      disko
    ];
  };
}
