{
  self,
  config,
  lib,
  ...
}: {
  config = {
    age.rekey = {
      inherit
        (self.rekeyConfig)
        masterIdentities
        extraEncryptionPubkeys
        ;
      hostPubkey = builtins.readFile "${self}/hosts/${config.networking.hostName}/secrets/host.pub";
      storageMode = "local";
      generatedSecretsDir = self.outPath + "/secrets/_generated/${config.networking.hostName}";
      localStorageDir = self.outPath + "/secrets/_rekeyed/${config.networking.hostName}";
    };
  };
  options.secrets = {
    globalSecretsFile = lib.mkOption {
      type = lib.types.path or null;
      default = null;
      description = "Specifies which file to use for global secrets.";
    };
    global = lib.mkOption {
      readOnly = true;
      default = builtins.extraBuiltins.rageImportEncrypted self.rekeyConfig.masterIdentities config.secrets.globalSecretsFile;
      type = lib.types.unspecified;
      description = "Read-only option to expose global secrets (secrets shared across all hosts).";
    };
    localSecretsFile = lib.mkOption {
      type = lib.types.path or null;
      default = null;
      description = "Specifies which file to use for per-host (local) secrets.";
    };
    local = lib.mkOption {
      readOnly = true;
      default = builtins.extraBuiltins.rageImportEncrypted self.rekeyConfig.masterIdentities config.secrets.localSecretsFile;
      type = lib.types.unspecified;
      description = "Read-only option to expose local secrets (secrets unique to this host).";
    };
  };
}
