{
  config,
  pkgs,
  ...
}: let
  browser = ["firefox.desktop"];

  # XDG MIME types
  associations = {
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "application/json" = browser;
    "application/pdf" = ["org.pwmt.zathura.desktop.desktop"];

    "text/html" = browser;
    "audio/*" = ["mpv.desktop"];
    "video/*" = ["mpv.dekstop"];
    "image/*" = ["imv.desktop"];

    "x-scheme-handler/about" = browser;
    #"x-scheme-handler/chrome" = ["chromium-browser.desktop"];
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = browser;
    "x-scheme-handler/discord" = ["WebCord.desktop"];
    "x-scheme-handler/mailto" = ["thunderbird.desktop"];
    "x-scheme-handler/ror2mm" = ["r2modman.desktop"];
  };
in {
  home.packages = [pkgs.xdg-utils];
  xdg = {
    # enable management of XDG base directories
    enable = true;

    # USER DIRS
    # XDG_CONFIG_HOME -> application configurations, analogous to /etc
    configHome = config.home.homeDirectory + "/.config";
    # XDG_CACHE_HOME -> application caches, analogous to /var/cache
    cacheHome = config.home.homeDirectory + "/.local/cache"; # (default is ~/.cache)
    # XDG_DATA_HOME -> application data, analogous to /usr/share
    dataHome = config.home.homeDirectory + "/.local/share";
    # XDG_STATE_HOME -> application states, analogous to /var/lib
    stateHome = config.home.homeDirectory + "/.local/state";

    # SYSTEM DIRS -> managed by Nix
    # systemDirs = {
    #   # XDG_CONFIG_DIRS
    #   config = "/usr/local/share:/usr/share";
    #   # XDG_DATA_DIRS
    #   data = "/etc/xdg";
    # };

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Media/Music";
      videos = "$HOME/Media/Videos";
      pictures = "$HOME/Media/Pictures";
      # file sharing between users, host & VMs, others on the LAN, etc.
      publicShare = "$HOME/PublicShare";
      # templates, for e.g. LibreOffice
      templates = "$HOME/Templates";
      extraConfig = {
        XDG_SCREENSHOT_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        XDG_DEV_DIR = "$HOME/Dev";
      };
    };

    # install programs & files to support MIME-info specification
    mime.enable = true;
    mimeApps = {
      # whether to manage $XDG_CONFIG_HOME/mimeapps.list
      enable = true;
      # default application for a given mimetype
      defaultApplications = associations;
    };
  };
}
