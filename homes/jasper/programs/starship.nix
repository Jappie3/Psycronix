{...}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true; # black line between shell prompts
      scan_timeout = 10;
      format = ''
        ╭─╴\[$username@$hostname\] $directory $git_branch$git_commit$git_state$git_metrics$git_status $nix_shell $cmd_duration
        ╰╴$character
      '';
      username = {
        show_always = true;
        # TODO colors
        format = "[$user]($style)";
      };
      hostname = {
        ssh_only = false;
        # TODO
        ssh_symbol = "";
        # TODO colors
        format = "[$ssh_symbol$hostname]($style)";
      };
      character = {
        #  󰅂  
        format = "$symbol";
        success_symbol = "[](green) ";
        error_symbol = "[](red) ";
      };
      cmd_duration = {
        format = "󰔚 [$duration]($style)";
      };
    };
  };
}
