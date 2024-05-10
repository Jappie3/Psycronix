{
  lib,
  config,
  pkgs,
  ...
}: {
  options.users = lib.attrsets.genAttrs ["jasper"] (
    user: {
      createUser = lib.options.mkOption {
        description = "Whether to create user ${user}";
        type = lib.types.bool;
        default = false;
      };
      nixTrusted = lib.options.mkOption {
        description = "Whether to add user ${user} to nix.settings.trusted-users";
        type = lib.types.bool;
        default = false;
      };
    }
  );
  config = {
    nix.settings.trusted-users = lib.mkIf config.users.jasper.nixTrusted ["jasper"];
    users = {
      mutableUsers = false;
      users = {
        # no root login allowed
        root.hashedPassword = "!";
        # create users according to config.users
        jasper = lib.mkIf config.users.jasper.createUser {
          isNormalUser = true;
          hashedPassword = "$6$Jhq9vZZCJlkdbntz$xFYnVDetR1BqT7EsKLEZ0.QdqpeOXtMtQP075buqc4cS9z8sqB/eoMdPjGymcNqcpnB0Jt91sdQxf49ffeUTN/";
          extraGroups =
            ["wheel" "input" "video" "audio" "systemd-journal"]
            ++ builtins.filter (g: builtins.hasAttr g config.users.groups) ["libvirtd" "networkmanager" "docker" "podman" "wireshark"];
          openssh.authorizedKeys.keyFiles = [(pkgs.writeText "ssh" "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDWbDBrUe/wJchfeDajmozOIDKrBN2pftsPqGlAFdnrEAAAABHNzaDo= jasper@Kainas")];
        };
      };
    };
  };
}
