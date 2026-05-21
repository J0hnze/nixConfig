{ pkgs, custom, ... }:

let
  desktop = custom.desktop or "cinnamon";

  waylandDesktops = [ "sway" "hyprland" "gnome" ];
  x11Desktops = [ "cinnamon" "xfce" "i3" "plasma" ];

in
{

  config = {

      assertions = [
    {
      assertion = builtins.elem desktop (x11Desktops ++ waylandDesktops);
      message = "Unsupported desktop environment: ${desktop}";
    }
  ];

    # Enable X for X11 desktops
    services.xserver.enable =
      builtins.elem desktop x11Desktops;

    # Display managers
    services.xserver.displayManager.lightdm.enable =
      builtins.elem desktop [ "cinnamon" "xfce" "i3" ];

    services.displayManager.sddm.enable =
      builtins.elem desktop [ "plasma" "hyprland" "sway" ];

    services.displayManager.gdm.enable =
      desktop == "gnome";
      

    # Desktop environments
    services.xserver.desktopManager.cinnamon.enable =
      desktop == "cinnamon";

    services.desktopManager.plasma6.enable =
      desktop == "plasma";

    services.desktopManager.gnome.enable =
      desktop == "gnome";

    services.xserver.desktopManager.xfce.enable =
      desktop == "xfce";

    # Window managers
    services.xserver.windowManager.i3.enable =
      desktop == "i3";

    programs.sway.enable =
      desktop == "sway";

    programs.hyprland.enable =
      desktop == "hyprland";
  };
}