{
  self,
  config,
  ...
}: {
  age.rekey = {
    inherit
      (self.rekeyConfig)
      masterIdentities
      extraEncryptionPubkeys
      ;
    hostPubkey = "${self}/hosts/${config.networking.hostName}/secrets/host.pub";
    storageMode = "local";
    generatedSecretsDir = "${self}/secrets/_generated/${config.networking.hostName}";
    localStorageDir = "${self}/secrets/_rekeyed/${config.networking.hostName}";
  };
}
