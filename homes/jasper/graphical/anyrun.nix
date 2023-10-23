{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.anyrun.homeManagerModules.default
  ];
  config.programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications # search applications
        shell # > run shell commands
        randr # :dp rotate & resize, change resolution, etc. (only Hyprland)
        #dictionary # :def look up definitions for words
        kidex # file search provided by Kidex
        rink # calculator & unit conversion
        symbols # search unicode symbols
        translate # translate text
        # :[target lang] [text] OR :[src lang]>[target lang] [text]
      ];
      # horizontal & vertical position
      x.fraction = 0.5;
      y.fraction = 0.2;
      # whether to ignore e.g. waybar, eww, ags
      ignoreExclusiveZones = true;
      # background, bottom, top, overlay
      layer = "overlay";
      # whether to hide icons
      hideIcons = false;
      # whether to hide the plugins info panel
      hidePluginInfo = true;
      # whether to close on click outside of anyrun
      closeOnClick = false;
      # whether to show results on start
      showResultsImmediately = false;
      maxEntries = null;
    };
    extraCss = ''
      * {
        all: unset;
        font-family: Lexend;
        font-size: 1.3rem;
      }

      #window, #match, #entry, #plugin, #main {
        background: transparent;
      }

      /* list of results for each plugin */
      #match.activatable {
        border-radius: 12px;
        /* padding on inside of every match */
        padding: .6rem;
      }

      /* selected match or plugin */
      #match:selected, #match:hover, #plugin:hover {
        background: rgba(255, 255, 255, .1);
      }

      /* search bar */
      #entry {
        background: rgba(255,255,255,.05);
        border: 1px solid rgba(255,255,255,.1);
        border-radius: 12px;
        margin: .3rem;
        padding: .3rem 1rem;
      }

      /* all plugins with matches for the query */
      list > #plugin {
        border-radius: 12px;
        /* margin to left & right of all plugins */
        margin: 0 .3rem;
        /* padding on the inside (between edge of plugin & matches) */
        padding: .3rem;
      }
      list > #plugin:first-child { margin-top: .3rem; }
      list > #plugin:last-child { margin-bottom: .3rem; }

      /* box that contains everything else */
      box#main {
        background: rgba(0, 0, 0, .5);
        box-shadow: inset 0 0 0 1px rgba(255, 255, 255, .1), 0 0 0 1px rgba(0, 0, 0, .5);
        border-radius: 12px;
        padding: .3rem;
      }
    '';
    extraConfigFiles."shell.ron".text = ''
      Config(
        // prefix to run shell commands
        prefix: ">",
        // shell -> retrieved via env var SHELL
      )
    '';
    extraConfigFiles."symbols.ron".text = ''
      Config(
        // prefix for searching symbols
        prefix: "",
        // custom user defined symbols
        symbols: {
          // "name": "text to be copied"
          "shrug": "¯\\_(ツ)_/¯",
        },
        max_entries: 3,
      )
    '';
    extraConfigFiles."applications.ron".text = ''
      Config(
        // also show the Desktop Actions defined in the desktop files, e.g. "New Window" from LibreWolf
        desktop_actions: false,
        max_entries: 5,
        // terminal used for running terminal based desktop entries, if left as `None` a static list of terminals is used
        terminal: Some("alacritty"),
      )
    '';
    extraConfigFiles."randr.ron".text = ''
      Config(
        prefix: ":dp",
        max_entries: 5,
      )
    '';
    extraConfigFiles."kidex.ron".text = ''
      Config(
        max_entries: 3,
      )
    '';
    extraConfigFiles."translate.ron".text = ''
      Config(
        prefix: ":",
        language_delimiter: ">",
        max_entries: 3,
      )
    '';
  };
}
