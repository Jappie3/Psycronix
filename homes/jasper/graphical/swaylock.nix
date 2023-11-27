{pkgs, ...}: {
  programs.swaylock = {
    enable = true;
    # use swaylock-effects instead of the default package
    package = pkgs.swaylock-effects;
    settings = {
      # whether to detach from controlling terminal after locking
      daemonize = true;
      show-failed-attempts = false;
      ignore-empty-password = true;
      show-keyboard-layout = false;
      disable-caps-lock-text = true;
      indicator-caps-lock = false;

      # text colors
      text-color = "ffffffff";
      text-clear-color = "00000000";
      text-caps-lock-color = "00000000";
      text-ver-color = "00000000";
      text-wrong-color = "00000000";

      # colors of the inside of the circle
      inside-color = "ff000000";
      inside-clear-color = "00000000";
      inside-caps-lock-color = "00000000";
      inside-ver-color = "00000000";
      inside-wrong-color = "00000000";

      # colors of layout text, bg & border
      layout-bg-color = "00000000";
      layout-border-color = "00000000";
      layout-text-color = "00000000";

      # colors of line between inside & ring
      line-color = "00000000";
      line-clear-color = "00000000";
      line-caps-lock-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";

      # color of ring
      ring-color = "000000ff";
      ring-clear-color = "ffffffff";
      ring-caps-lock-color = "000000ff";
      ring-ver-color = "000000ff";
      ring-wrong-color = "000000ff";

      # color of key press highlight segments
      key-hl-color = "ffffffff";
      bs-hl-color = "ffffffff";
      caps-lock-bs-hl-color = "ffffffff";
      caps-lock-key-hl-color = "ffffffff";

      # lines that separate highlighted segments
      separator-color = "00000000";

      screenshots = false;
      image = "$FLAKE/.theme/current_wallpaper";

      # background color
      color = "00000000";

      clock = true;
      datestr = "%d/%m/%Y";
      font-size = "60";

      # indicator active in grace period
      indicator = true;
      # indicator visible only after grace period
      #indicator-idle-visible = true;
      indicator-radius = 160;
      # grace period in sec
      grace = 0;
      grace-no-mouse = true;
      grace-no-touch = true;

      # effects
      fade-in = 1.2;
      effect-blur = "6x7";
      effect-vignette = "0.5:0.5";
    };
  };
}
