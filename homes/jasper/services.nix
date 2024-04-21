{
  pkgs,
  config,
  ...
}: {
  systemd.user = {
    startServices = true;
    services.load-theme = {
      Install.WantedBy = ["default.target"];
      Service = {
        Restart = "on-failure";
        ExecStart = pkgs.writeShellScript "load-theme.sh" ''
          set -e
          if [[ -e /tmp/LOAD_THEME_ACTIVATING ]]; then
            # we're changing the theme already, don't do anything
            exit 0
          fi

          # only switch themes if the loc file exists
          if [[ ! -e "${config.age.secrets.loc.path}" ]]; then
            exit 1
          fi

          THEME_FILE="/tmp/theme"

          # make sure we don't get in a loop by activating hm specialisations later -> create 'lockfile'
          touch /tmp/LOAD_THEME_ACTIVATING
          # check when sun rises & sets based on the current location
          case "$(${pkgs.sunwait}/bin/sunwait poll $(<"${config.age.secrets.loc.path}"))" in
            "NIGHT")
              # load dark
              "$(${pkgs.ripgrep}/bin/rg ExecStart /run/current-system/etc/systemd/system/home-manager-jasper.service | ${pkgs.coreutils}/bin/cut -d ' ' -f 2)/specialisation/dark/activate"
              ${pkgs.coreutils}/bin/echo "dark" > "$THEME_FILE"
            ;;
            "DAY")
              # load light
              "$(${pkgs.ripgrep}/bin/rg ExecStart /run/current-system/etc/systemd/system/home-manager-jasper.service | ${pkgs.coreutils}/bin/cut -d ' ' -f 2)/specialisation/light/activate"
              ${pkgs.coreutils}/bin/echo "light" > "$THEME_FILE"
            ;;
            *)
              exit 1
            ;;
          esac
          rm /tmp/LOAD_THEME_ACTIVATING
        '';
      };
    };
  };
}
