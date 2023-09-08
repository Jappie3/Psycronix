{
  config,
  inputs,
  pkgs,
  ...
}: {
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
          x = 6;
          y = 6;
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
      draw_bold_text_with_bright_colors = true;
      colors = {
        primary = {
          background = "#1d1f21";
          foreground = "#c5c8c6";
        };
        dim_foreground = "#828482";
        bright_foreground = "#eaeaea";
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
            foreground = "#1d1f21";
            background = "#e9ff5e";
          };
          # all characters after the first one in the hint label
          end = {
            foreground = "#e9ff5e";
            background = "#1d1f21";
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
          foreground = "#c5c8c6";
          background = "#1d1f21";
        };
        # colors used to draw the selection area
        selection = {
          text = "CellBackground";
          background = "CellForeground";
        };
        normal = {
          black = "#1d1f21";
          red = "#cc6666";
          green = "#b5bd68";
          yellow = "#f0c674";
          blue = "#81a2be";
          magenta = "#b294bb";
          cyan = "#8abeb7";
          white = "#c5c8c6";
        };
        bright = {
          black = "#666666";
          red = "#d54e53";
          green = "#b9ca4a";
          yellow = "#e7c547";
          blue = "#7aa6da";
          magenta = "#c397d8";
          cyan = "#70c0b1";
          white = "#eaeaea";
        };
        dim = {
          black = "#131415";
          red = "#864343";
          green = "#777c44";
          yellow = "#9e824c";
          blue = "#556a7d";
          magenta = "#75617b";
          cyan = "#5b7d78";
          white = "#828482";
        };
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
