{...}: {
  flake = {
    nixosModules = {
      web-eid = import ./web-eid.nix;
      sshd = import ./sshd.nix;
      secure_boot = import ./secure_boot.nix;
    };
    homeManagerModules = {
      theme_config = import ./theme_config.nix;
    };
  };
}
