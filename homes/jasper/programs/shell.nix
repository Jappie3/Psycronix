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

      rm = "rm -i";
      cp = "cp -i";
      mv = "mv-i";
    };

    sessionVariables = {
      ANSIBLE_COW_SELECTION = "random";
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