{
  config,
  input,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;

    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;

    userSettings = {
      "git.autofetch" = true;
      "keyboard.dispatch" = "keyCode";
      "files.autoSave" = "onFocusChange";
      "explorer.autoReveal" = true;

      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = true;

      "editor.formatOnSave" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.minimap.autohide" = true;
      "editor.minimap.renderCharacters" = true;

      "workbench.startupEditor" = "none";
      "workbench.colorTheme" = "Dark Modern";
    };

    extensions = with pkgs.vscode-extensions; [
      kamadorueda.alejandra
      pkief.material-icon-theme
      rust-lang.rust-analyzer
      redhat.vscode-yaml
    ];
  };
}
