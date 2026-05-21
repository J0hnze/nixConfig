{ pkgs, lib, config, ... }:

let
  cfg = config.my.display.dynamicMonitors;

  script = pkgs.writeShellScriptBin "dynamic-monitors" ''
    #!/usr/bin/env bash

    # Get connected outputs in order
    outputs=($(xrandr --query | grep " connected" | awk '{print $1}'))

    # Exit if only one screen
    if [ ''${#outputs[@]} -lt 2 ]; then
      exit 0
    fi

    # Start position
    offset=0

    # Loop through displays and place them side-by-side
    for output in "''${outputs[@]}"; do
      mode=$(xrandr | awk -v o="$output" '
        $1==o && /connected/ {getline; print $1; exit}
      ')

      if [ -n "$mode" ]; then
        xrandr --output "$output" --auto --mode "$mode" --pos ''${offset}x0
        offset=$((offset + $(xrandr | awk -v o="$output" '
          $1==o && /connected/ {getline; print $1}
        ' | cut -d'x' -f1)))
      fi
    done
  '';

in
{
  options.my.display.dynamicMonitors.enable = lib.mkEnableOption "Dynamic monitor layout";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ script ];

    services.xserver.displayManager.setupCommands = ''
      ${script}/bin/dynamic-monitors
    '';
  };
}
