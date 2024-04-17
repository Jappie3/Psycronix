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
        Restart = "always";
        ExecStart = pkgs.writeShellScript "load-theme.sh" ''
          set -e
          THEME_FILE="/tmp/theme"
          # only switch themes if the loc file exists
          if [[ -e "${config.age.secrets.loc.path}" ]]; then
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
          fi
        '';
      };
    };
  };
}
