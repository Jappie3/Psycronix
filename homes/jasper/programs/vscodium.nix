{
  config,
  input,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nil
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;

    # whether to allow updating/installing extensions via the GUI
    mutableExtensionsDir = false;

    userSettings = {
      # keycodes cuz position of key > what letter pressed
      "keyboard.dispatch" = "keyCode";
      "git.autofetch" = true;
      "explorer.autoReveal" = true;
      "files.autoSave" = "onFocusChange";
      "files.associations" = {
        "**/roles/**/*.yaml" = "ansible";
        "**/roles/**/*.yml" = "ansible";
      };

      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = true;
      "explorer.confirmDragAndDrop" = false;
      "explorer.confirmDelete" = false;

      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;
      "[python]"."editor.formatOnPaste" = false; # Black does not support this
      "editor.formatOnType" = false;
      "editor.suggest.showWords" = false;
      "editor.smoothScrolling" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.minimap.autohide" = true;
      "editor.minimap.renderCharacters" = true;
      "editor.fontFamily" = "JetBrainsMono Nerd Font, Material Design Icons, 'monospace', monospace";

      "workbench.startupEditor" = "none";
      "workbench.colorTheme" = "Dark Modern";

      # fix codium crashing on mouse hover
      # also this looks hella sexy for some reason
      "window.titleBarStyle" = "custom";

      "redhat.telemetry.enabled" = false;

      # use Nil as LSP
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.formatterPath" = "alejandra";
    };

    # TODO figure out how to use https://github.com/nix-community/nix-vscode-extensions/
    extensions = with pkgs.vscode-extensions;
      [
        # General
        mhutchie.git-graph
        naumovs.color-highlight
        pkief.material-icon-theme
        pkief.material-product-icons
        tomoki1207.pdf
        #hbenl.vscode-test-explorer
        #hbenl.test-adapter-converter

        # Nix
        bbenoist.nix
        jnoortheen.nix-ide
        kamadorueda.alejandra
        arrterian.nix-env-selector
        mkhl.direnv

        # K8s
        ms-kubernetes-tools.vscode-kubernetes-tools

        # Ansible
        redhat.vscode-yaml
        #redhat.ansible

        # Rust
        rust-lang.rust-analyzer
        serayuzgur.crates
        tamasfe.even-better-toml
        #swellaby.vscode-rust-test-adapter

        # Python
        ms-python.python
        #ms-python.isort
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vsliveshare";
          publisher = "ms-vsliveshare";
          version = "1.0.5892";
          sha256 = "sha256-e/cJONR/4Lai18h7kHJU8UEn5yrUZHPoITAyZpLenTA=";
        }
        {
          name = "test-adapter-converter";
          publisher = "ms-vscode";
          version = "0.1.8";
          sha256 = "c9b6f75ae77a31255612ea7dc8d3786387f99494422f7932ac66f107c4a9843b";
        }
        {
          name = "vscode-test-explorer";
          publisher = "hbenl";
          version = "2.21.1";
          sha256 = "7c7c9e3ddf1f60fb7bccf1c11a256677c7d1c7e20cdff712042ca223f0b45408";
        }
        {
          name = "vscode-rust-test-adapter";
          publisher = "swellaby";
          version = "0.11.0";
          sha256 = "2207dc211179e095e6f65daf5637fb94524e5522340838038d04fe1f0e853b84";
        }
        {
          name = "isort";
          publisher = "ms-python";
          version = "2023.11.12061012";
          sha256 = "19ada003b74e2b3a7c153a69edd4b50fc479836640254e7955a2a88a33aab276";
        }
        {
          name = "ansible";
          publisher = "redhat";
          version = "2.7.98";
          sha256 = "6f7678d087906ed61c8b62c0e3f3a52647ea301efc71644d4cd59df3d95f872e";
        }
        {
          name = "yuck";
          publisher = "eww-yuck";
          version = "0.0.3";
          sha256 = "0c84e02de75a3b421faedb6ef995e489a540ed46b94577388d74073d82eaadc3";
        }
      ];
  };
}
