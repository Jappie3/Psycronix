{
  self,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = with self.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    sshd
    users
  ];

  users.jasper = {
    createUser = true;
    nixTrusted = true;
  };

  boot = {
    tmp.cleanOnBoot = true;
    consoleLogLevel = 0;
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_scsi"
      "virtio_blk"
    ];
    loader.grub = {
      enable = true;
      efiSupport = true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  time.timeZone = "Europe/Oslo";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      sandbox = true;
      keep-outputs = true;
      keep-derivations = true;
      log-lines = 25;
      warn-dirty = false;
    };
  };

  age.secrets = {
    einzig_flugel = {
      rekeyFile = self.outPath + "/secrets/wg-cluster/psks/einzig_flugel.age";
      owner = "systemd-network";
      generator.script = {pkgs, ...}: "${pkgs.wireguard-tools}/bin/wg genpsk";
    };
    einzig_kainas = {
      rekeyFile = self.outPath + "/secrets/wg-cluster/psks/einzig_kainas.age";
      owner = "systemd-network";
      generator.script = {pkgs, ...}: "${pkgs.wireguard-tools}/bin/wg genpsk";
    };
    einzig = {
      rekeyFile = self.outPath + "/secrets/wg-cluster/keys/einzig.age";
      owner = "systemd-network";
      generator.script = {
        pkgs,
        file,
        ...
      }: ''
        priv=$(${pkgs.wireguard-tools}/bin/wg genkey)
        ${pkgs.wireguard-tools}/bin/wg pubkey <<< "$priv" > ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
        echo "$priv"
      '';
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [51820 80 443];
    };
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.einzig.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = builtins.readFile "${self}/secrets/wg-cluster/keys/flugel.pub";
            PresharedKeyFile = config.age.secrets.einzig_flugel.path;
            AllowedIPs = ["10.100.0.2"];
          }
          {
            PublicKey = builtins.readFile "${self}/secrets/wg-cluster/keys/kainas.pub";
            PresharedKeyFile = config.age.secrets.einzig_kainas.path;
            AllowedIPs = ["10.100.0.3"];
          }
        ];
      };
    };
    networks = {
      "30-wan" = {
        matchConfig.MACAddress = "96:00:03:59:81:f6";
        networkConfig = {
          Address = ["2a01:4f9:c010:ce49::1/64" "65.21.50.100/32"];
        };
        # see https://docs.hetzner.com/cloud/servers/primary-ips/primary-ip-configuration/
        routes = [
          {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          }
          {
            Gateway = "fe80::1";
            GatewayOnLink = true;
          }
        ];
      };
      "50-wg" = {
        matchConfig.Name = "wg0";
        address = ["10.100.0.1/24"];
        networkConfig.IPv4Forwarding = true;
      };
    };
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    streamConfig = ''
      server {
        listen 0.0.0.0:443;
        proxy_pass 10.100.0.2:443;
      }
      server {
        listen 0.0.0.0:80;
        proxy_pass 10.100.0.2:80;
      }
    '';
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "dvorak";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [vim git tree];

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
