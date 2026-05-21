{ config, pkgs, lib, ... }:

let
  cfg = config.my.display.kde;
in
{
  options.my.display.kde.enable = lib.mkEnableOption "KDE Plasma display setup";

  config = lib.mkIf cfg.enable {

    # ─────────────────────────────
    # DISPLAY MANAGER (UPDATED PATHS)
    # ─────────────────────────────
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = false;
    };

    # ─────────────────────────────
    # DESKTOP ENVIRONMENT (UPDATED PATH)
    # ─────────────────────────────
    services.desktopManager.plasma6.enable = true;

    # ─────────────────────────────
    # X11 SERVER (still valid)
    # ─────────────────────────────
    services.xserver = {
      enable = true;

      videoDrivers = [ "modesetting" ];
      #videoDrivers = [ "vmware" ];
    };

    # ─────────────────────────────
    # VMware / guest tools (safe to keep)
    # ─────────────────────────────
    hardware.graphics.enable = true;

    # ─────────────────────────────
    # Display debug log (safe)
    # ─────────────────────────────
  #  services.xserver.displayManager.sessionCommands = ''
  #    echo "[DISPLAY] session started $(date)" > /tmp/display-layout.log
  #  '';
  services.xserver.displayManager.sessionCommands = ''
  ${pkgs.xorg.xrandr}/bin/xrandr \
    --output Virtual-1 --primary --mode 1920x1200 --pos 0x0 \
    --output Virtual-2 --mode 1920x1080 --pos 1920x0
    '';
    }; 

  

        #deviceSection = ''
      #  Option "DynamicResize" "true"
      #'';
}