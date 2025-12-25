{pkgs, config, lib, user, ...}:
let
  cfg = config.hyprland;
in
{
  options.hyprland = {
    enable = lib.mkEnableOption "Configures a Hyprland session.";
  };

  config = lib.mkIf cfg.enable {
    # Hyprland doesn't provide a display manager like a typical desktop
    # environment does (e.g. gdm for Gnome), so we need to bring our own.
    # The display manager provides a login window to start a session, which
    # sounds like it would overlap with the program that provides the lock
    # screen when the system goes idle, but these are actually two separate
    # things.
    services.greetd = {
      enable = true;      
    };
    programs.regreet = {
      enable = true;
      settings = {
        background.path = ./../wallpapers/grayscale-palm-leaf.jpg;
        appearance.greeting_msg = "Nice to see you";
      };
    };

    # Enable hyprland at the system level so that it can integrate with
    # systemd.
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Declaratively configure Hyprland.
    home-manager.users.${user.username} = {
      programs.kitty.enable = true;
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          exec-once = [
            "regreet"
          ];
          decoration.rounding = 5;
        };
      };
    };
  };
}
