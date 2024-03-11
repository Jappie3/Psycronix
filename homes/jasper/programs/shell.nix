{
  config,
  inputs,
  pkgs,
  ...
}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = ["erasedups" "ignoredups" "ignorespace"];

    shellAliases = {
      ll = "ls -lh --color=auto";
      l = "ls -lah --color=auto";

      search = "nix search nixpkgs";
      copy = "copy() { cat \"$1\" | wl-copy; }; copy";

      svim = "sudo -E vim";
      snvim = "sudo -E nvim";

      ka = "kubectl get all --all-namespaces";
      da = "docker ps -a";

      dir = "dir --color=auto";
      vdir = "vdir --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      ip = "ip --color=auto";
      ls = "ls --color=auto";

      rm = "trash -v";
      cp = "cp -iv";
      mv = "mv -iv";
    };

    sessionVariables = {
      # I present to you: the List of Shame
      # aka applications that don't follow the XDG base directory standard
      # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
      # also check out https://github.com/b3nj5m1n/xdg-ninja
      TLDR_CACHE_DIR = "\$XDG_CACHE_HOME/tldr";
      ANDROID_HOME = "\$XDG_DATA_HOME/android";
      ANSIBLE_HOME = "\$XDG_DATA_HOME/ansible";
      CARGO_HOME = "\$XDG_DATA_HOME/cargo";
      CUDA_CACHE_PATH = "\$XDG_CACHE_HOME/nv";
      GOPATH = "\$XDG_DATA_HOME/go";
      GTK2_RC_FILES = "\$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
      PLATFORMIO_CORE_DIR = "\$XDG_DATA_HOME/platformio";
      PYWAL_CACHE_DIR = "\$XDG_CACHE_HOME/wal";
      STARSHIP_CACHE = "\$XDG_CACHE_HOME/starship";
      WINEPREFIX = "\$XDG_DATA_HOME/wine";
      XCURSOR_PATH = "\$XDG_DATA_HOME/icons";
      XCOMPOSECACHE = "\$XDG_CACHE_HOME/X11/xcompose";
    };

    # extra commands (interactive shells only)
    initExtra = ''
      # control + backspace -> remove word
      stty werase '^H'
    '';

    # extra commands (these get executed even in non-interactive shells)
    #bashrcExtra = ''
    #'';
  };
}
