{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    vscodium
    nil
    black
    isort
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
      "git.autofetch" = false;
      "diffEditor.ignoreTrimWhitespace" = false;
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

      "editor.formatOnSave" = false;
      "editor.formatOnPaste" = false;
      "editor.formatOnType" = false;

      "[python]" = {
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = false; # Black does not support this
        "editor.defaultFormatter" = "ms-python.python";
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };
      "isort.check" = true;
      "isort.showNotifications" = "always";
      "isort.args" = ["--profile" "black"];
      "python.formatting.provider" = "black";
      #"python.formatting.blackArgs" = ["--quiet"];

      "editor.suggest.showWords" = false;
      "editor.smoothScrolling" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.minimap.autohide" = true;
      "editor.minimap.renderCharacters" = true;
      "editor.fontFamily" = "JetBrainsMono Nerd Font, Material Design Icons, 'monospace', monospace";

      # fix codium crashing on mouse hover
      "window.titleBarStyle" = "custom";

      "workbench.startupEditor" = "welcomePageInEmptyWorkbench";
      # don't show the walkthrough section on the welcome page
      "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      # this somehow doesn't work (I love electron)
      #"window.autoDetectColorScheme" = true;
      # so we do this instead
      "workbench.colorTheme" =
        if config.theme.variant == "dark"
        then "Default Dark Modern"
        else "Default Light Modern";

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
        redhat.vscode-yaml
        ms-kubernetes-tools.vscode-kubernetes-tools

        # Nix
        bbenoist.nix
        jnoortheen.nix-ide
        kamadorueda.alejandra
        arrterian.nix-env-selector
        mkhl.direnv

        # Rust
        rust-lang.rust-analyzer
        serayuzgur.crates
        tamasfe.even-better-toml

        # Python
        ms-python.python
        ms-python.vscode-pylance

        # Go
        golang.go
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vsliveshare";
          publisher = "ms-vsliveshare";
          version = "1.0.5892";
          sha256 = "sha256-e/cJONR/4Lai18h7kHJU8UEn5yrUZHPoITAyZpLenTA=";
        }
        {
          name = "isort";
          publisher = "ms-python";
          version = "2023.11.12061012";
          sha256 = "19ada003b74e2b3a7c153a69edd4b50fc479836640254e7955a2a88a33aab276";
        }
      ];
  };
}
