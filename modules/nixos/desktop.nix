{ config, pkgs, custom, ... }:

let
  desktop = custom.desktop or "cinnamon";
in
{
  config = {

    # Enable X server for X11 desktops
    services.xserver.enable =
      builtins.elem desktop [ "cinnamon" "plasma" "gnome" "xfce" "i3" ];

    # Display managers
    services.xserver.displayManager.lightdm.enable =
      builtins.elem desktop [ "cinnamon" "xfce" "i3" ];

    services.displayManager.sddm.enable =
      desktop == "plasma";

    services.xserver.displayManager.gdm.enable =
      desktop == "gnome";

    # Desktop environments
    services.xserver.desktopManager.cinnamon.enable =
      desktop == "cinnamon";

    services.desktopManager.plasma6.enable =
      desktop == "plasma";

    services.xserver.desktopManager.gnome.enable =
      desktop == "gnome";

    services.xserver.desktopManager.xfce.enable =
      desktop == "xfce";

    # i3 (X11)
    services.xserver.windowManager.i3.enable =
      desktop == "i3";

    # Sway (Wayland i3-style)
    programs.sway.enable =
      desktop == "sway";

    # Hyprland
    programs.hyprland.enable =
      desktop == "hyprland";
  };
}
