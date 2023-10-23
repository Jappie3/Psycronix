{...}: {
  flake.nixosModules = {
    web-eid = import ./web-eid.nix;
    sshd = import ./sshd.nix;
  };
}
