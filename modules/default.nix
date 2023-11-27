{...}: {
  flake = {
    nixosModules = {
      web-eid = import ./web-eid.nix;
      sshd = import ./sshd.nix;
    };
    homeManagerModules = {
      global_theme = import ./global_theme.nix;
    };
  };
}
