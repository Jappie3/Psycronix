{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  monitor = "eDP-1";
  colors = config.theme.colors;
  HTMLToRGB = html: "rgb(${lib.strings.removePrefix "#" html})";
  HTMLToRGBA = html: alfa: "rgba(${lib.strings.removePrefix "#" html}${alfa})";
in {
  imports = [
    inputs.hypridle.homeManagerModules.hypridle
    inputs.hyprlock.homeManagerModules.hyprlock
  ];
  home.packages = [
    inputs.hypridle.packages.${pkgs.system}.hypridle
    inputs.hyprlock.packages.${pkgs.system}.hyprlock
    inputs.wayfreeze.packages.${pkgs.system}.wayfreeze
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
  ];
  services.hypridle = {
    enable = true;
    listeners = [
      {
        timeout = 300; # 5 mins
        onTimeout = "${inputs.hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock";
        onResume = "";
      }
      {
        timeout = 600; # 10 mins
        onTimeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        onResume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
      {
        timeout = 720; # 12 mins
        onTimeout = "${pkgs.systemd}/bin/systemctl suspend";
        onResume = "${pkgs.systemd}/bin/hyprctl dispatch dpms on";
      }
    ];
    lockCmd = "${inputs.hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock"; # on dbus lock event, e.g. loginctl lock-session
    unlockCmd = ""; # on dbus unlock event, e.g. loginctl unlock-session
    beforeSleepCmd = "${inputs.hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock"; # on debus prepare_sleep event
    afterSleepCmd = ""; # on dbus post prepare_sleep event
    ignoreDbusInhibit = false; # don't ignore dbus idle-inhibit requests (used by steam, firefox, etc.)
  };
  programs.hyprlock = {
    enable = true;
    general = {
      disable_loading_bar = false;
      grace = 0;
      hide_cursor = true;
      no_fade_in = false;
    };
    backgrounds = [
      {
        #monitor = "";
        path = "screenshot";
        blur_size = 12;
        blur_passes = 3;
        noise = 0.0117;
        contrast = 0.8917;
        brightness = 0.8172;
        vibrancy = 0.1686;
        vibrancy_darkness = 0.05;
        shadow_passes = 3;
        shadow_size = 3;
        shadow_color = "rgb(0,0,0)";
        shadow_boost = 1.2;
      }
    ];
    input-fields = [
      {
        monitor = monitor;
        size = {
          width = 300;
          height = 30;
        };
        dots_size = 0.33;
        dots_spacing = 0.15;
        dots_center = true;
        dots_rounding = -1; # -1 = circle, -2 = follow input-field rounding
        outer_color = "rgb(0, 51, 102)";
        outline_thickness = 2;
        inner_color = "rgb(6, 10, 15)";
        font_color = "rgb(255, 255, 255)";
        fade_on_empty = true;
        placeholder_text = "";
        hide_input = false;
        position = {
          x = 0;
          y = -100;
        };
        rounding = -1; # -1 = complete rounding (circle)
        halign = "center";
        valign = "center";
        shadow_passes = 3;
        shadow_size = 3;
        shadow_color = "rgb(0,0,0)";
        shadow_boost = 1.2;
      }
    ];
    labels = [
      {
        monitor = monitor;
        text = "<i>The keeper is fading away; the creator has not yet come.</i>";
        color = "rgb(255, 255, 255)";
        shadow_passes = 3;
        shadow_size = 3;
        shadow_color = "rgb(0,0,0)";
        shadow_boost = 1.2;
        font_size = 16;
        font_family = "Garamond-libre";
        position = {
          x = 0;
          y = -20;
        };
        halign = "center";
        valign = "center";
      }
      {
        monitor = monitor;
        text = "<i>But the world shall burn no more, for you shall ascend.</i>";
        color = "rgb(255, 255, 255)";
        shadow_passes = 3;
        shadow_size = 3;
        shadow_color = "rgb(0,0,0)";
        shadow_boost = 1.2;
        font_size = 16;
        font_family = "Garamond-libre";
        position = {
          x = 0;
          y = -50;
        };
        halign = "center";
        valign = "center";
      }
    ];
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd.enable = true;
    xwayland.enable = true;

    plugins = [
      # https://github.com/DreamMaoMao/hycov
      inputs.hycov.packages.${pkgs.system}.hycov
    ];

    settings = {
      plugin = {
        hycov = {
          overview_gappo = 60; # gaps width from screen edge
          overview_gappi = 24; # gaps width from clients
          enable_hotarea = 1; # enable mouse cursor hotarea
          hotarea_monitor = "all"; # monitor name which hotarea is in, default is all
          hotarea_pos = 1; # position of hotarea (1: bottom left, 2: bottom right, 3: top left, 4: top right)
          hotarea_size = 10; # hotarea size, 10x10
          swipe_fingers = 4; # finger number of gesture,move any directory
          move_focus_distance = 100; # distance for movefocus,only can use 3 finger to move
          enable_gesture = 0; # enable gesture
          disable_workspace_change = 0; # disable workspace change when in overview mode
          disable_spawn = 0; # disable bind exec when in overview mode
          auto_exit = 1; # enable auto exit when no client in overview
          auto_fullscreen = 0; # auto make active window maximize after exit overview
          only_active_workspace = 0; # only overview the active workspace
          only_active_monitor = 0; # only overview the active monitor
          enable_alt_release_exit = 0; # alt swith mode arg,see readme for detail
          alt_replace_key = "Alt_L"; # alt swith mode arg,see readme for detail
          alt_toggle_auto_next = 0; # auto focus next window when toggle overview in alt swith mode
          click_in_cursor = 1; # when click to jump,the target windwo is find by cursor, not the current foucus window.
          hight_of_titlebar = 0; # height deviation of title bar hight
        };
      };

      monitor = [
        # name    resolution@framerate    pos       scale
        "eDP-1,   1920x1080@165.009995,   0x0,      1"
        "DP-2,    3840x2160@60.000000,    1920x0,   2"
        ",        preferred,              auto,     1"
        # name    reserved area   T   B   L   R
        "eDP-1,   addreserved,    35, 0,  0,  0"
      ];

      env = [
        # log WLR stuff
        #"HYPRLAND_LOG_WLR,1"

        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

        # "/usr/lib/polkit-kde-authentication-agent-1"
        # #"blueman-applet"
        # #"discover-overlay &"

        # Noise suppression
        "sleep 6; noisetorch -i" # -i -> load suppressor for input
        # Gamma adjustment
        "wlsunset -T 6000 -t 5000 &"
        # wallpaper
        "swww init && sleep .5"
        # Alacritty (to eliminate future startup delay)
        "[ workspace special:alacritty silent ] alacritty"
        # Swayidle
        # only un-pause notifs again if they were un-paused before locking
        # TODO fix notification daemon
        # "swayidle -w timeout 180 'if [[ \"$(dunstctl is-paused)\" == \"false\" ]]; then dunstctl set-paused true; touch /tmp/swayidle_paused_notifs_true; fi; hyprctl dispatch exec swaylock' resume 'if [[ -e /tmp/swayidle_paused_notifs_true ]]; then dunstctl set-paused false; rm /tmp/swayidle_paused_notifs_true; fi' before-sleep 'hyprctl dispatch exec swaylock'"
        "swayidle -w timeout 180 'hyprctl dispatch exec swaylock' before-sleep 'hyprctl dispatch exec swaylock'"
      ];

      exec = [
        # Swww - a Solution to all your Wayland Wallpaper Woes
        "swww img $FLAKE/.theme/current_wallpaper"
        # Ags - Aylur's GTK Shell
        "WAYLAND_DISPLAY=wayland-1 ags -b hyprland"
        # set cursor theme
        "hyprctl setcursor ${config.theme.cursor_name} ${builtins.toString config.theme.cursor_size}"
      ];

      general = {
        gaps_in = config.theme.window_inner_gap;
        gaps_out = config.theme.window_outer_gap;
        gaps_workspaces = 0;
        border_size = 2;
        no_border_on_floating = false;
        layout = "dwindle";
        no_cursor_warps = true;
        no_focus_fallback = true;
        resize_on_border = false;
        cursor_inactive_timeout = 0; # 0 = forever
        allow_tearing = false; # master switch for tearing
        "col.active_border" = "${HTMLToRGBA colors.color0 "ff"} ${HTMLToRGBA colors.color5 "ff"} 45deg";
        "col.inactive_border" = "${HTMLToRGBA colors.color7 "aa"}";
      };

      group = {
        insert_after_current = true;
        # group border color
        "col.border_active" = "${HTMLToRGBA colors.color0 "ff"} ${HTMLToRGBA colors.color5 "ff"} 45deg";
        "col.border_inactive" = "${HTMLToRGBA colors.color7 "aa"}";
        # locked group border color
        "col.border_locked_active" = "";
        "col.border_locked_inactive" = "";
        groupbar = {
          # group bar color
          "col.active" = "${HTMLToRGBA colors.color3 "ff"} ${HTMLToRGBA colors.color5 "ff"} 45deg";
          "col.inactive" = "${HTMLToRGBA colors.color7 "aa"}";
          # locked group bar color
          "col.locked_active" = "${HTMLToRGBA colors.color3 "ff"} ${HTMLToRGBA colors.color5 "ff"} 45deg";
          "col.locked_inactive" = "${HTMLToRGBA colors.color7 "aa"}";
          render_titles = false;
          gradients = false;
        };
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
          natural_scroll = true; # the only right way
          disable_while_typing = true;
          middle_button_emulation = false; # LMB & RMB simultaneously = middle click, disables middle click touchpad area
          clickfinger_behavior = false; # 1, 2 & 3-finger button presses -> LMB, RMB & MMB respectively, disables interpretation based on location
          tap-to-click = true; # 1, 2 & 3-finger taps -> LMB, RMB & MMB respectively
          drag_lock = false; # lifting finger for a short time won't drop the dragged item
          #tap-and-drag = true;
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
          size = 10;
          passes = 3;
          ignore_opacity = true;
          new_optimizations = true;
          xray = false;
          noise = 0;
          contrast = 1.1;
          brightness = 1.2;
          vibrancy = 0.0;
          vibrancy_darkness = 0.0;
          special = false;
        };

        rounding = config.theme.border_radius;
        drop_shadow = true;

        active_opacity = 0.9;
        inactive_opacity = 0.7;
        fullscreen_opacity = 1.0;

        shadow_range = 20;
        shadow_render_power = 3; # power of falloff, [1-4]
        shadow_ignore_window = true; # only render behind window
        shadow_offset = "0 5"; # vector for shadow offset
        shadow_scale = 1.0;
        #"col.shadow" = "rgba(1a1a1aee)";
        "col.shadow" = "rgba(00000099)";

        dim_inactive = false;
        dim_special = 0.2; # dim when special workspace open, [0.0 - 1.0]
        dim_around = 0.4; # dim of dimaround window rule, [0.0 - 1.0]
      };

      animations = {
        enabled = true;
        first_launch_animation = true;

        bezier = [
          "defaultBezier, 0.05, 0.9, 0.1, 1.05"
          "overshot_fast, 0.05, 0.9, 0.1, 1.1"
          "overshot_slow_accel, 0.7, 0.6, 0.1, 1.1"
          "windowIn, 0.06, 1.2, 0.25, 1"
          "windowOut, 0.17, 0.69, 0.01, 0.74"
          "windowResize, 0.04, 0.67, 0.38, 1"
          "bounce, 1, 1.6, 0.1, 0.85"
          "hyprnostretch, 0.05, 0.9, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "fluent_decel, 0.1, 1, 0, 1"
        ];

        animation = [
          # NAME, ONOFF, SPEED, CURVE, STYLE
          "windowsIn, 1, 8, windowIn, slide #popin 20%"
          "windowsOut, 1, 7, windowOut, slide #popin 70%"
          "windowsMove, 1, 7, fluent_decel"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, overshot_slow_accel"
        ];
      };

      dwindle = {
        # windows retain floating size when tiled
        pseudotile = false;
        # split doesn't change regardless of what happens to container
        preserve_split = true;
        # window split direction is based on cursor's position on the window
        smart_split = false;
        # resizing direction determined by cursor's position on the window
        smart_resizing = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        #force_default_wallpaper = true; # -1 = random [-1 - 3], 0 = disables anime bg

        # controls vfr, true to conserve resources
        vfr = true;
        # controls vrr, 0-off, 1-on, 2-fullscreen only
        vrr = 0;
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
        swallow_regex = "^(thunar|thunderbird|org.remmina.Remmina)$";

        # whether to focus an app that sends an activate request
        focus_on_activate = false;
        # enable direct scanout to reduce lag when there is only 1 fullscreen application
        no_direct_scanout = true;
        # whether mouse moving to different monitor should focus it
        mouse_move_focuses_monitor = true;
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

      workspace = [
        "special:scratchpad, gapsout:50"
      ];

      "$MOD" = "SUPER";
      bind = [
        # flags:
        # l -> locked, aka. works also when an input inhibitor (e.g. a lockscreen) is active.
        # r -> release, will trigger on release of a key.
        # e -> repeat, will repeat when held.
        # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
        # m -> mouse

        "$MOD, U, exec, alacritty msg create-window || alacritty &,"
        "$MOD, A, togglespecialworkspace, scratchpad"
        "$MOD SHIFT, A, movetoworkspacesilent, special:scratchpad"
        "$MOD, J, exec, killall .anyrun-wrapped || anyrun"
        "$MOD, H, exec, firefox &,"
        "$MOD, D, exec, thunar &,"
        "$MOD, I, killactive,"
        "$MOD, K, togglefloating,"
        "$MOD, X, fullscreen,"
        "$MOD, Z, pin"
        #bind = $MOD, M, exit,

        "$MOD, Q, exec, ags --toggle-window SideRight"

        # scroll through existing workspaces with MOD + arrow keys
        "$MOD SHIFT, left, workspace, e-1"
        "$MOD SHIFT, right, workspace, e+1"
        # scroll through existing workspaces with MOD + scroll
        "$MOD, mouse_down, workspace, e-1"
        "$MOD, mouse_up, workspace, e+1"

        # take screenshot of the entire screen & copy it
        '', print, exec, ${pkgs.grim}/bin/grim - | ${inputs.shadower.packages.${pkgs.system}.shadower}/bin/shadower | ${pkgs.wl-clipboard}/bin/wl-copy''
        # take screenshot of the entire screen & save it to ~/Pictures/screenshots/
        ''$MOD, print, exec, ${pkgs.grim}/bin/grim - | ${inputs.shadower.packages.${pkgs.system}.shadower}/bin/shadower > "$XDG_SCREENSHOT_DIR/$(date +'%Y-%m-%dT%H:%M:%S').png"''
        # take screenshot of an area & copy it
        ''$MOD, O, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${inputs.shadower.packages.${pkgs.system}.shadower}/bin/shadower | ${pkgs.wl-clipboard}/bin/wl-copy''
        # take screenshot of an area & edit it using Swappy
        #''$MOD LEFTCTRL, O, exec, grim -g "$(slurp)" - | swappy -f -''

        # create window group
        "$MOD, N, togglegroup"
        # cycle through windows in group
        "$MOD, T, changegroupactive, f"
        "$MOD SHIFT, T, changegroupactive, b"
        # lock active group
        "$MOD, S, lockactivegroup, toggle"

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

        # switch workspaces with MOD + [',.pyfgcrl]
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

        # move active window to a workspace with MOD + SHIFT + [',.pyfgcrl]
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

        # move active window silently to a workspace with MOD + LEFTCTRL + [',.pyfgcrl]
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
        "stayfocused, title:^()$, class:^(steam)$"
        "float, class:^(virt-manager)$"
        "float, class:^(.*polkit-kde-authentication-agent.*)$"
        "float, class:^(pavucontrol)$"
        "float, class:^(com.saivert.pwvucontrol)$"
        "float, class:eid-viewer"

        "suppressevent maximize, class:org.remmina.Remmina"

        "float, class:^(nm-connection-editor)$"
        "float, class:^(wdisplays)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(.blueman-manager-wrapped)$"
        "float, class:^(.blueman-sendto-wrapped)$"
        "float, class:^(wpa_gui)$"

        "float, class:^(zenity)$"
        "float, class:^(Yad)$"
        "float, class:^(yad)$"

        "float, title: Open Folder, class: electron"
        "float, title: Open folder as vault, class: electron"

        "float, title: Open Folder, class:^(codium)$"
        "float, title: Open File, class:^(codium)$"

        "float, title:^(File Operation Progress)$"
        "float, title:^(Compress)$"
        "float, title:^(Confirm to replace files)$"

        "float, class:thunderbird, title:^(Edit.*)$"
        "size 860 670, class:thunderbird, title:^(Edit.*)$"
        "center, class:thunderbird, title:^(Edit.*)$"
        "float, class:thunderbird title:Compact folders"
        "float, class:thunderbird title:Password Required - Mozilla Thunderbird"
        "float, class:thunderbird title:Thunderbird - Choose User Profile"
        "float, class:thunderbird title:Create New Calendar"
        "float, class:thunderbird title:Downloading Certificate"
        "float, class:thunderbird title:Select Certificate"
        "suppressevent fullscreen, class:thunderbird"

        # start Discord in workspace 8 by default
        "workspace 8 silent, title:^(.*(Disc|WebC|ArmC)ord.*)$"
        # start Spotify in workspace 9 by default
        "workspace 9 silent, class:^(Spotify)$"
        # start Tidal in workspace 9 by default
        "workspace 9 silent, class:^(tidal-hifi)$"

        # Firefox
        "float, title:Password Required - Mozilla Firefox"
        "float, title:Load PKCS#11 Device Driver"
        # Firefox PiP sticky & floating
        "pin, title:^(Picture-in-Picture)$"
        "float, title:^(Picture-in-Picture)$"
        # Firefox opening file
        "suppressevent fullscreen, title:^(Opening.*)$, class:firefox"
        "suppressevent maximize, title:^(Opening.*)$, class:firefox"
        "float, title:^(Opening.*)$, class:firefox"
        # Mic & camera popup
        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
        # NoScript TODO fix this
        "float, title:^(Extension: \(NoScript\) - NoScript XSS Warning — Mozilla Firefox)$"
        "suppressevent fullscreen, title:^(Extension: \(NoScript\) - NoScript XSS Warning — Mozilla Firefox)$"

        # idle inhibit
        "idleinhibit focus, class:^(mpv|.+exe)$"
        "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(firefox)$"

        "dimaround, class:^(gcr-prompter)$"
      ];

      layerrule = [
        # get rid of black border on screenshots
        "noanim, ^(selection)$"
        # xray blur for lockscreen
        "xray on, lockscreen"
        "blur, lockscreen"
      ];
    };
  };
}
