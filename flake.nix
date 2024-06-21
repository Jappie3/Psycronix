{
  description = "Jappie3's NixOS config";

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix-rekey,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in {
    # all my hosts -> ./hosts
    nixosConfigurations = import ./hosts {inherit nixpkgs self lib;};

    # modules, both NixOS & hm -> ./modules
    nixosModules = import ./modules/nixos {inherit inputs;};
    homeManagerModules = import ./modules/home-manager {inherit inputs;};

    rekeyConfig = {
      masterIdentities = ["${self}/secrets/YK1_NIX_RAGE.pub"];
      extraEncryptionPubkeys = ["${self}/secrets/YK2_NIX_RAGE.pub"];
    };

    agenix-rekey = agenix-rekey.configure {
      userFlake = self;
      nodes = self.nixosConfigurations;
    };

    packages = forAllSystems (pkgs: {
      aarch64_sd_image = inputs.nixos-generators.nixosGenerate {
        # nix build .#aarch64_sd_image
        # sudo dd if=result/sd-image/nixos-sd-image-[...]-aarch64-linux.img of=/dev/sda status=progress bs=4M
        format = "sd-aarch64";
        system = "aarch64-linux";
        specialArgs = {inherit self lib;};
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./images/aarch-sd-image
        ];
      };
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          git
          alejandra
          rage
          age-plugin-yubikey
          agenix-rekey.packages.${system}.default
        ];
        DIRENV_LOG_FORMAT = "";
        # configure nix-plugins with the extra builtins file, needed for per-host secret files
        NIX_CONFIG = ''
          plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
          extra-builtins-file = ${./.}/nix/extra-builtins.nix
        '';
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    impermanence.url = "github:nix-community/impermanence";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:jappie3/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun-nixos-options.url = "github:n3oney/anyrun-nixos-options";

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    schizofox = {
      url = "github:schizofox/schizofox";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpak.follows = "nixpak";
      };
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs"; # mesa version needs to be the same, see https://github.com/hyprwm/hyprlock/issues/239
    hypridle.url = "github:hyprwm/Hypridle";
    hyprcursor.url = "github:hyprwm/hyprcursor";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    shadower.url = "github:n3oney/shadower";

    vigiland.url = "github:jappie3/vigiland";
    wayfreeze.url = "github:jappie3/wayfreeze";

    hyprcursor-phinger = {
      url = "github:jappie3/hyprcursor-phinger";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zotero-nix.url = "github:camillemndn/zotero-nix";

    neovim-flake = {
      url = "github:notashelf/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    conduit = {
      url = "gitlab:famedly/conduit/next";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
