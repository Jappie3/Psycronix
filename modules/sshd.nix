{
  lib,
  pkgs,
  ...
}: {
  services.openssh = lib.mkDefault {
    # enable OpenSSH daemon
    enable = true;
    # systemd will start an SSHD instance for each incoming connection
    startWhenNeeded = true;
    # port on which SSH daemon listens
    ports = [22];
    # automatically open firewall
    openFirewall = true;
    # text shown upon connecting
    banner = "\n\tThe great gates have been sealed.\n\t\tNone shall enter.\n\t\tNone shall leave.\n\n\n";
    # some security stuff
    settings = {
      X11Forwarding = false;
      UseDns = false;
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # key exchange algorithms recommended by nixpkgs#ssh-audit
      # see https://github.com/numtide/srvos/blob/main/nixos/common/openssh.nix
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };
    hostKeys = [
      {
        type = "rsa";
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
      }
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };
}
