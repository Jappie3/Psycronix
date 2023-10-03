{
  inputs,
  pkgs,
  ...
}: {
  config.wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemdIntegration = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;

    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    settings = {
      monitor = [
        # name    resolution@framerate    pos       scale
        "eDP-1,   1920x1080@165.009995,   0x0,      1"
        "DP-2,    3840x2160@60.000000,    1920x0,   2"
        ",        preferred,              auto,     1"
        # name    reserved area   T   B   L   R
        "eDP-1,   addreserved,    35, 0,  0,  0"
      ];

      plugin = {
        split-monitor-workspaces = {
          count = 10;
        };
      };

      env = [
        # log WLR stuff
        #"HYPRLAND_LOG_WLR,1"
        # avoid loading Nvidia modules - not tested on NixOS
        #"__EGL_VENDOR_LIBRARY_FILENAMES,/usr/share/glvnd/egl/vendor.d/50_mesa.json"
        # force GBM as backend (buffer API) - causes problems with Firefox
        #"GBM_BACKEND,nvidia-drm"

        # add some locations to PATH
        #"PATH,$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.local/share/JetBrains/Toolbox/scripts"

        # SYSTEMD-SSH-AGENT
        #"SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/ssh-agent.socket"

        # XDG base directory specification
        #"XDG_DATA_HOME,$HOME/.local/share"
        #"XDG_CONFIG_HOME,$HOME/.config"
        #"XDG_STATE_HOME,$HOME/.local/state"
        #"XDG_CACHE_HOME,$HOME/.cache"
        #"XDG_CONFIG_DIRS,/etc/xdg"
        #"XDG_DATA_DIRS,~/.local/share/:/usr/local/share/:/usr/share/"
        #"XDG_RUNTIME_DIR,"
        #"XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dunst &"
        "/usr/lib/polkit-kde-authentication-agent-1"
        #"blueman-applet"
        #"discover-overlay &"
        "sleep 6; noisetorch -i" # -i -> load supressor for input
        "wlsunset -T 6000 -t 5000 &"

        # wallpaper
        "swww init && sleep .5"

        # Alacritty (to eliminate future startup delay)
        "[ workspace special:alacritty silent ] alacritty"

        # Swayidle
        # only un-pause notifs again if they were un-paused before locking
        "swayidle -w timeout 180 'if [[ \"$(dunstctl is-paused)\" == \"false\" ]]; then dunstctl set-paused true; touch /tmp/swayidle_paused_notifs_true; fi; hyprctl dispatch exec swaylock' resume 'if [[ -e /tmp/swayidle_paused_notifs_true ]]; then dunstctl set-paused false; rm /tmp/swayidle_paused_notifs_true; fi' before-sleep 'hyprctl dispatch exec swaylock'"
      ];

      exec = [
        # set wallpaper
        "swww img ~/Media/Pictures/Walls/alena-aenami-rooflinesgirl-1k-2.jpg"
        # quit & re-launch ags
        # a window very briefly pops up before the widget shows -> silently send it to special:ags
        "[ workspace special:ags silent ] \"sleep .5; ags -q; sleep .5; ags\""
      ];

      general = {
        gaps_in = 2;
        gaps_out = 6;
        border_size = 2;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        "col.group_border_active" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.group_border" = "rgba(595959aa)";
        layout = "dwindle";
        no_cursor_warps = true;
        no_focus_fallback = true;
        resize_on_border = false;
        #cursor_inactive_timeout = 3;
      };

      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
        #kb_model =;
        # bind key to execute 'hyprctl switchxkblayout' has same effect
        #kb_options = grp:alt_shift_toggle;
        #kb_rules =;

        # 1 -> cursor movement always changes focus
        follow_mouse = 1;
        # 2 -> cursor focus detached from keyboard focus, clicking a window moves keyboard focus
        #follow_mouse = 2;

        # mouse scrollwheel feels weird with natural scroll
        natural_scroll = false;
        accel_profile = "flat";
        sensitivity = 0;
        numlock_by_default = true;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          middle_button_emulation = false;
          clickfinger_behavior = true;
          drag_lock = false;
        };
      };

      "device:foostan-corne" = {
        kb_layout = "us";
        kb_variant = "dvorak";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = false;
      };

      decoration = {
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          #xray = true; # why did I ever put this in here lol
          noise = 0;
          contrast = 1;
          brightness = 0.8;
        };

        # this value is tied to the Ags config so change it there as well @ future me
        rounding = 12;
        drop_shadow = true;

        shadow_range = 20;
        shadow_render_power = 3;
        shadow_offset = "0 5";
        shadow_ignore_window = true;
        #"col.shadow" = "rgba(1a1a1aee)";
        "col.shadow" = "rgba(00000099)";

        #dim_inactive = true;
        #dim_strength = 0.06;
      };

      animations = {
        # this somehow errors
        #enabled = true;

        bezier = [
          "defaultBezier, 0.05, 0.9, 0.1, 1.05"
          "hyprnostretch, 0.05, 0.9, 0.1, 1;"
        ];

        animation = [
          "windows, 1, 7, hyprnostretch"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, hyprnostretch"
        ];
      };

      dwindle = {
        # windows retain floating size when tiled
        pseudotile = false;
        # split doesn't change regardless of what happens to container
        preserve_split = true;
        # window split direction is based on cursor's position on the window
        smart_split = true;
        # resizing direction determined by cursor's position on the window
        smart_resizing = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        #force_hypr_chan = true;
        # controls vfr, true to conserve resources
        vfr = true;
        # controls vrr, 0-off, 1-on, 2-fullscreen only
        vrr = 2;
        # auto-reload config
        disable_autoreload = false;

        # VESA Display Power Management Scaling (standard for power management of video monitors)
        # set to off -> wake up monitors when mouse moves / key is pressed
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = false;

        # mouse focus follows mouse when drag-and-dropping
        always_follow_on_dnd = true;
        # keyboard-interactive layers keep their focus on mouse movement (e.g. wofi)
        layers_hog_keyboard_focus = true;

        # animate manual resizes / moves
        animate_manual_resizes = true;
        # animate windows dragged by mouse
        animate_mouse_windowdragging = true;

        enable_swallow = true;
        # class regex for windows that should be swallowed
        swallow_regex = "thunar|thunderbird|alacritty";

        # whether to focus an app that sends an activate request
        focus_on_activate = false;
        # enable direct scanout to reduce lag when there is only 1 fullscreen application
        no_direct_scanout = true;
        # whether mouse moving to different monitor should focus it
        mouse_move_focuses_monitor = true;

        # window groups
        render_titles_in_groupbar = false;
        group_insert_after_current = true;
        groupbar_gradients = false;
      };

      debug = {
        # debug overlay, disable VFR for accurate results
        overlay = false;
        # flash areas updated with damage tracking
        damage_blink = false;
        # redraw only needed bits (2-full, 1-monitor, 0-none), DO NOT CHANGE
        damage_tracking = 2;

        disable_logs = false;
        disable_time = false;
        enable_stdout_logs = false;
      };

      # this config is for dvorak
      "$MOD" = "SUPER";
      bind = [
        # flags:
        # l -> locked, aka. works also when an input inhibitor (e.g. a lockscreen) is active.
        # r -> release, will trigger on release of a key.
        # e -> repeat, will repeat when held.
        # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
        # m -> mouse

        "$MOD, U, exec, alacritty msg create-window || alacritty &,"
        "$MOD, Escape, togglespecialworkspace"
        "$MOD, J, exec, killall .anyrun-wrapped || anyrun"
        "$MOD, H, exec, firefox &,"
        "$MOD, D, exec, thunar &,"
        "$MOD, S, exec, wlogout"
        "$MOD, I, killactive,"
        "$MOD, K, togglefloating,"
        "$MOD, X, fullscreen,"
        "$MOD, z, pin"
        #bind = $MOD, M, exit,

        "$MOD, Q, exec, ags toggle-window SideRight"

        # scroll through existing workspaces with MOD + arrow keys
        "$MOD SHIFT, left, workspace, e-1"
        "$MOD SHIFT, right, workspace, e+1"
        # scroll through existing workspaces with MOD + scroll
        "$MOD, mouse_down, workspace, e-1"
        "$MOD, mouse_up, workspace, e+1"

        # take screenshot of the entire screen & copy it
        #", print, exec, grimblast --cursor copy screen"
        '', print, exec, grim - | shadower | wl-copy''
        # take screenshot of the entire screen & save it to ~/Pictures/screenshots/
        #"$MOD, print, exec, grimblast --cursor save screen ~/Pictures/screenshots/$(date +'%Y-%m-%dT%H:%M:%S').png"
        ''$MOD, print, exec, grim - | shadower > "~/Pictures/screenshots/$(date +'%Y-%m-%dT%H:%M:%S').png"''
        # take screenshot of an area & copy it
        #"$MOD, O, exec, grimblast --cursor copy area"
        ''$MOD, O, exec, grim -g "$(slurp)" - | shadower | wl-copy''
        # take screenshot of an area & edit it using Swappy
        #''$MOD LEFTCTRL, O, exec, grim -g "$(slurp)" - | swappy -f -''

        # create tabbed window
        "$MOD, n, togglegroup"
        # cycle through tabbed windows
        "$MOD, t, changegroupactive, f"
        "$MOD SHIFT, t, changegroupactive, b"

        # alt tab behaviour but with $MOD
        "$MOD, Tab, cyclenext"
        "$MOD, Tab, bringactivetotop,"

        # move focus with MOD + arrow keys
        "$MOD, left, movefocus, l"
        "$MOD, right, movefocus, r"
        "$MOD, up, movefocus, u"
        "$MOD, down, movefocus, d"
        # swap windows
        "$MOD LEFTCTRL, left, movewindow, l"
        "$MOD LEFTCTRL, right, movewindow, r"
        "$MOD LEFTCTRL, down, movewindow, d"
        "$MOD LEFTCTRL, up, movewindow, u"

        # switch workspaces with MOD + [0-9]
        "$MOD, apostrophe, workspace, 1"
        "$MOD, comma, workspace, 2"
        "$MOD, period, workspace, 3"
        "$MOD, p, workspace, 4"
        "$MOD, y, workspace, 5"
        "$MOD, f, workspace, 6"
        "$MOD, g, workspace, 7"
        "$MOD, c, workspace, 8"
        "$MOD, r, workspace, 9"
        "$MOD, l, workspace, 10"

        # move active window to a workspace with MOD + SHIFT + [0-9]
        "$MOD SHIFT, apostrophe, movetoworkspace, 1"
        "$MOD SHIFT, comma, movetoworkspace, 2"
        "$MOD SHIFT, period, movetoworkspace, 3"
        "$MOD SHIFT, p, movetoworkspace, 4"
        "$MOD SHIFT, y, movetoworkspace, 5"
        "$MOD SHIFT, f, movetoworkspace, 6"
        "$MOD SHIFT, g, movetoworkspace, 7"
        "$MOD SHIFT, c, movetoworkspace, 8"
        "$MOD SHIFT, r, movetoworkspace, 9"
        "$MOD SHIFT, l, movetoworkspace, 10"

        # move active window silently to a workspace with MOD + LEFTCTRL + [0-9]
        "$MOD LEFTCTRL, apostrophe, movetoworkspacesilent, 1"
        "$MOD LEFTCTRL, comma, movetoworkspacesilent, 2"
        "$MOD LEFTCTRL, period, movetoworkspacesilent, 3"
        "$MOD LEFTCTRL, p, movetoworkspacesilent, 4"
        "$MOD LEFTCTRL, y, movetoworkspacesilent, 5"
        "$MOD LEFTCTRL, f, movetoworkspacesilent, 6"
        "$MOD LEFTCTRL, g, movetoworkspacesilent, 7"
        "$MOD LEFTCTRL, c, movetoworkspacesilent, 8"
        "$MOD LEFTCTRL, r, movetoworkspacesilent, 9"
        "$MOD LEFTCTRL, l, movetoworkspacesilent, 10"

        # move workspaces between monitors
        "$MOD ALT, 1, movecurrentworkspacetomonitor, 0"
        "$MOD ALT, 2, movecurrentworkspacetomonitor, 1"
        "$MOD ALT, 3, movecurrentworkspacetomonitor, 2"
      ];

      bindm = [
        # move/resize windows with MOD + LMB/RMB and dragging (bindm -> bind mouse)
        "$MOD, mouse:272, movewindow"
        "$MOD, mouse:273, resizewindow"
      ];

      bindle = [
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        #, XF86MonBrightnessUp, exec, xbacklight -inc 5
        #, XF86MonBrightnessDown, exec, xbacklight -dec 5
      ];

      bindl = [
        ", XF86AudioMedia, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioStop, exec, playerctl stop"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        # todo XF86AudioRaiseVolume, XF86AudioLowerVolume, XF86AudioMute
      ];

      windowrulev2 = [
        "noshadow, floating:0"
        "float, class:Steam, title:^(Friends.*)$"
        "float, title:Steam Settings"
        "float, class:^(virt-manager)$"
        #"float, class:^(libreoffice.*)$"
        "float, class:^(.*polkit-kde-authentication-agent.*)$"
        "float, class:^(pavucontrol)$"
        "float, class:^(com.saivert.pwvucontrol)$"
        #"float, class:^(Signal)$"

        "float, class:^(nm-connection-editor)$"
        "float, class:^(wdisplays)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(.blueman-manager-wrapped)$"
        "float, class:^(wpa_gui)$"

        "float, class:^(zenity)$"
        "float, class:^(Yad)$"
        "float, class:^(yad)$"

        "float, title: Open Folder, class: electron"

        "float, title: Open Folder, class:^(codium)$"

        "float, title:^(File Operation Progress)$"
        "float, title:^(Compress)$"
        "float, title:^(Confirm to replace files)$"

        "float, class:thunderbird, title:^(Edit.*)$"
        "size 860 670, class:thunderbird, title:^(Edit.*)$"
        "center, class:thunderbird, title:^(Edit.*)$"
        "nofullscreenrequest, class:thunderbird"

        "float, class:wlogout, title:wlogout"
        "nofullscreenrequest, class:wlogout, title:wlogout"
        #"fullscreen, class:wlogout, title:wlogout"
        "size 1920 1080, class:wlogout, title:wlogout"
        "center, class:wlogout, title:wlogout"
        "noborder, class:wlogout, title:wlogout"
        #"dimaround, class:wlogout, title:wlogout"
        #"pin, class:wlogout, title:wlogout"
        #"noanim, class:wlogout, title:wlogout"
        "animation popin 80%, class:wlogout, title:wlogout"

        # start Discord in workspace 8 by default
        "workspace 8 silent, title:^(.*(Disc|WebC)ord.*)$"
        # start Spotify in workspace 9 by default
        "workspace 9 silent, class:^(Spotify)$"
        # start Tidal in workspace 9 by default
        "workspace 9 silent, class:^(tidal-hifi)$"

        # Alacritty opacity
        "opacity 0.8 0.6,class:^(Alacritty)$"

        # Firefox PiP sticky & floating
        "pin, title:^(Picture-in-Picture)$"
        "float, title:^(Picture-in-Picture)$"
        # Firefox opening file
        "nofullscreenrequest, title:^(Opening.*)$, class:firefox"
        "float, title:^(Opening.*)$, class:firefox"
        # Mic & camera popup
        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
        # NoScript TODO fix this
        "float, title:^(Extension: \(NoScript\) - NoScript XSS Warning — Mozilla Firefox)$"
        "nofullscreenrequest, title:^(Extension: \(NoScript\) - NoScript XSS Warning — Mozilla Firefox)$"

        # idle inhibit
        "idleinhibit focus, class:^(mpv|.+exe)$"
        "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(firefox)$"

        "dimaround, class:^(gcr-prompter)$"
      ];

      layerrule = [
        "noanim, ^(selection)$"
        "blur, eww"
      ];
    };
  };
}
