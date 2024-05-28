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
  agenix-rekey = inputs.agenix-rekey.nixosModules.default;
  rekey_conf = self.nixosModules.rekey_conf;
  disko = inputs.disko.nixosModules.disko;

  # extraSpecialArgs that all hosts need
  sharedArgs = {inherit self lib inputs;};
in {
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
        agenix-rekey
        rekey_conf
      ];
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
