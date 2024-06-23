_: {
  web-eid = import ./web-eid.nix;
  sshd = import ./sshd.nix;
  secure_boot = import ./secure_boot.nix;
  router = import ./router.nix;
  users = import ./users.nix;
  ntp = import ./ntp.nix;
  secret_config = import ./secret_config.nix;
  cpu_amd = import ./hardware/cpu_amd.nix;
  laptop_power = import ./hardware/laptop_power.nix;
}
