{ pkgs, lib, ... }:
let
  extensions = with pkgs.gnomeExtensions; [
    pop-shell
    blur-my-shell
  ];

  emptyStrArray = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
in
{
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = with lib.gvariant; {
          "org/gnome/shell" = {
            enabled-extensions = builtins.map (x: x.extensionUuid) (
              lib.filter (p: p ? extensionUuid) extensions
            );
          };

          "org/gnome/desktop/wm/keybindings" = {
            close = [
              "<Super>q"
              "<Alt>F4"
            ];
            minimize = [ "<Super>comma" ];
            toggle-maximized = [ "<Super>m" ];
            move-to-monitor-left = emptyStrArray;
            move-to-monitor-right = emptyStrArray;
            move-to-monitor-up = emptyStrArray;
            move-to-monitor-down = emptyStrArray;
            move-to-workspace-down = emptyStrArray;
            move-to-workspace-up = emptyStrArray;
            switch-to-workspace-down = [ "<Primary><Super>Down" ];
            switch-to-workspace-up = [ "<Primary><Super>Up" ];
            switch-to-workspace-left = emptyStrArray;
            switch-to-workspace-right = emptyStrArray;
            maximize = emptyStrArray;
            unmaximize = emptyStrArray;
          };

          "org/gnome/shell/keybindings" = {
            open-application-menu = emptyStrArray;
            toggle-message-tray = [ "<Super>v" ];
            toggle-overview = emptyStrArray;
          };

          "org/gnome/mutter/keybindings" = {
            toggle-tiled-left = emptyStrArray;
            toggle-tiled-right = emptyStrArray;
          };

          "org/gnome/mutter/wayland/keybindings" = {
            restore-shortcuts = emptyStrArray;
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            screensaver = [ "<Super>Escape" ];
            home = [ "<Super>f" ];
            www = [ "<Super>b" ];
            terminal = [ "<Super>t" ];
            email = [ "<Super>e" ];
            rotate-video-lock-static = emptyStrArray;
          };

          "org/gnome/shell/extensions/pop-shell" = {
            toggle-tiling = [ "<Super>y" ];
            toggle-floating = [ "<Super>g" ];
            tile-enter = [ "<Super>Return" ];
            tile-accept = [ "Return" ];
            tile-reject = [ "Escape" ];
            toggle-stacking-global = [ "<Super>s" ];
            pop-workspace-down = [
              "<Shift><Super>Down"
              "<Shift><Super>j"
            ];
            pop-workspace-up = [
              "<Shift><Super>Up"
              "<Shift><Super>k"
            ];
            pop-monitor-left = [
              "<Shift><Super>Left"
              "<Shift><Super>h"
            ];
            pop-monitor-right = [
              "<Shift><Super>Right"
              "<Shift><Super>l"
            ];
            pop-monitor-down = emptyStrArray;
            pop-monitor-up = emptyStrArray;
            focus-left = [
              "<Super>Left"
              "<Super>h"
            ];
            focus-down = [
              "<Super>Down"
              "<Super>j"
            ];
            focus-up = [
              "<Super>Up"
              "<Super>k"
            ];
            focus-right = [
              "<Super>Right"
              "<Super>l"
            ];
          };
        };
      }
    ];
  };

  # services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  #   [org/gnome/desktop/wm/keybindings]
  #   close=['<Super>q', '<Alt>F4']
  #   minimize=['<Super>comma']
  #   toggle-maximized=['<Super>m']
  #   move-to-monitor-left=[]
  #   move-to-monitor-right=[]
  #   move-to-monitor-up=[]
  #   move-to-monitor-down=[]
  #   move-to-workspace-down=[]
  #   move-to-workspace-up=[]
  #   switch-to-workspace-down=['<Primary><Super>Down']
  #   switch-to-workspace-up=['<Primary><Super>Up']
  #   switch-to-workspace-left=[]
  #   switch-to-workspace-right=[]
  #   maximize=[]
  #   unmaximize=[]
  #
  #   [org/gnome/shell/keybindings]
  #   open-application-menu=[]
  #   toggle-message-tray=['<Super>v']
  #   toggle-overview=[]
  #
  #   [org/gnome/mutter/keybindings]
  #   toggle-tiled-left=[]
  #   toggle-tiled-right=[]
  #
  #   [org/gnome/mutter/wayland/keybindings]
  #   restore-shortcuts=[]
  #
  #   [org/gnome/settings-daemon/plugins/media-keys]
  #   screensaver=['<Super>Escape']
  #   home=['<Super>f']
  #   www=['<Super>b']
  #   terminal=['<Super>t']
  #   email=['<Super>e']
  #   rotate-video-lock-static=[]
  #
  #   [org/gnome/shell/extensions/pop-shell]
  #   toggle-tiling=['<Super>y']
  #   toggle-floating=['<Super>g']
  #   tile-enter=['<Super>Return']
  #   tile-accept=['Return']
  #   tile-reject=['Escape']
  #   toggle-stacking-global=['<Super>s']
  #   pop-workspace-down=['<Shift><Super>Down', '<Shift><Super>j']
  #   pop-workspace-up=['<Shift><Super>Up', '<Shift><Super>k']
  #   pop-monitor-left=['<Shift><Super>Left', '<Shift><Super>h']
  #   pop-monitor-right=['<Shift><Super>Right', '<Shift><Super>l']
  #   pop-monitor-down=[]
  #   pop-monitor-up=[]
  #   focus-left=['<Super>Left', '<Super>h']
  #   focus-down=['<Super>Down', '<Super>j']
  #   focus-up=['<Super>Up', '<Super>k']
  #   focus-right=['<Super>Right', '<Super>l']
  # '';
}
