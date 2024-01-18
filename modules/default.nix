{...}: {
  flake = {
    nixosModules = {
      web-eid = import ./web-eid.nix;
      sshd = import ./sshd.nix;
    };
    homeManagerModules = {
      theme_config = import ./theme_config.nix;
    };
  };
}
