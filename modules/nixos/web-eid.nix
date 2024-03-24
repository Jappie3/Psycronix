{
  pkgs,
  lib,
  config,
  ...
}: {
  # Web eID support for Firefox - https://web-eid.eu/
  # TODO test if I need hardware.enableAllFirmware or hardware.enableRedistributableFirmware for this
  programs.firefox = {
    enable = true;
    # enable Web eID support
    nativeMessagingHosts.packages = [pkgs.web-eid-app];
    # load PKCS#11 modules via the p11-kit-proxy module
    policies.SecurityDevices.p11-kit-proxy = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";
  };
  services = {
    # PC-SC smart card daemon
    pcscd.enable = true;
  };
  environment = {
    # see https://nixos.wiki/wiki/Web_eID
    etc."pkcs11/modules/opensc-pkcs11".text = ''
      module: ${pkgs.opensc}/lib/opensc-pkcs11.so
    '';
    systemPackages = with pkgs; [
      firefox
      eid-mw # eID middleware
      ccid # ccid drivers for pcsclite
      acsccid # PC/SC driver which supports ACS CCID smart card readers
      pinentry # GNUPG interface for passphrase input
      opensc # set of libraries to access smart cards
      p11-kit # library for loading & sharing PKCS#11 modules
    ];
  };
}
