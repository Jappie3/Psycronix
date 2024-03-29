{
  config,
  inputs,
  pkgs,
  ...
}: let
  colors = config.theme.colors;
in {
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      window = {
        #opacity = 0.6;
        startup_mode = "Windowed";
        # allow terminal applications to change the window title
        dynamic_title = true;
        # full: borders & title bar
        # none: no borders or title bar
        decorations = "none";
        # spread additional padding evenly around terminal content
        dynamic_padding = true;
        padding = {
          x = 2;
          y = 2;
        };
      };
      scrolling.history = 10000;
      font = {
        size = 11.0;
        normal.family = "monospace";
        normal.style = "Regular";
        bold.family = "monospace";
        bold.style = "Bold";
        italic.family = "monospace";
        italic.style = "Italic";
        bold_italic.family = "monospace";
        bold_italic.style = "Bold Italic";
      };
      colors = {
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = colors.color0;
          foreground = colors.color15;
          # dim_foreground & bright_foreground -> calculated based on foreground
        };
        # CellBackground & CellForeground -> reference the affected cell
        cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        vi_mode_cursor = {
          text = "CellBackground";
          cursor = "CellForeground";
        };
        # colors for search bar & match highlighting
        search = {
          matches = {
            foreground = "#000000";
            background = "#ffffff";
          };
          focused_match = {
            foreground = "#ffffff";
            background = "#000000";
          };
        };
        # keyboard hints
        hints = {
          start = {
            foreground = colors.color0;
            background = "#e9ff5e";
          };
          # all characters after the first one in the hint label
          end = {
            foreground = "#e9ff5e";
            background = colors.color0;
          };
        };
        # colors for indicator displaying the position in history
        # during search & vi mode
        line_indicator = {
          foreground = "None";
          background = "None";
        };
        # colors for footer bar used by search regex input, hyprling preview, etc.
        footer_bar = {
          foreground = colors.color15;
          background = colors.color0;
        };
        # colors used to draw the selection area
        selection = {
          text = "CellBackground";
          background = "CellForeground";
        };
        normal = {
          black = colors.color0;
          red = colors.color1;
          green = colors.color2;
          yellow = colors.color3;
          blue = colors.color4;
          magenta = colors.color5;
          cyan = colors.color6;
          white = colors.color7;
        };
        bright = {
          black = colors.color8;
          red = colors.color9;
          green = colors.color10;
          yellow = colors.color11;
          blue = colors.color12;
          magenta = colors.color13;
          cyan = colors.color14;
          white = colors.color15;
        };
        # will be calculated automatically based on normal colors
        #dim = {};
        # index colors include all colors from 16 to 256
        # not set -> filled with sensible defaults
        indexed_colors = [];
        # whether window.opacity applies to all cell backgrounds
        # or only to the default background
        transparent_background_colors = false;
      };
      #bell = {};
      cursor = {
        style = {
          # Block, Underline, Beam
          shape = "Block";
          # Never, Off, On, Always
          blinking = "Off";
        };
        #vi_mode_style = "None";
        #blink_interval = 750;
        #blink_timeout = 5;
        unfocused_hollow = true;
        #thickness = 0.15;
      };
      live_config_reload = true;
      #shell = {};
      mouse = {
        hide_when_typing = false;
      };
    };
  };
}
