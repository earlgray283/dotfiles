{ ... }:

{
  # AeroSpace window manager
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      after-login-command = [ ];
      after-startup-command = [ ];
      start-at-login = true;

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = false;

      key-mapping.preset = "qwerty";

      gaps = {
        inner = {
          horizontal = 0;
          vertical = 0;
        };
        outer = {
          left = 0;
          bottom = 0;
          top = 0;
          right = 0;
        };
      };

      mode.main.binding = {
        ctrl-enter = "exec-and-forget open /Applications/Ghostty.app/";
        ctrl-shift-enter = "exec-and-forget open -n '/Applications/Firefox.app/'";

        ctrl-slash = "layout tiles horizontal vertical";
        ctrl-comma = "layout accordion horizontal vertical";

        ctrl-left = "focus left";
        ctrl-down = "focus down";
        ctrl-up = "focus up";
        ctrl-right = "focus right";

        ctrl-shift-left = "move left";
        ctrl-shift-down = "move down";
        ctrl-shift-up = "move up";
        ctrl-shift-right = "move right";

        ctrl-shift-q = "macos-native-minimize";

        ctrl-minus = "resize smart -50";
        ctrl-equal = "resize smart +50";

        ctrl-1 = "workspace 1";
        ctrl-2 = "workspace 2";
        ctrl-3 = "workspace 3";
        ctrl-4 = "workspace 4";
        ctrl-5 = "workspace 5";
        ctrl-6 = "workspace 6";
        ctrl-7 = "workspace 7";
        ctrl-8 = "workspace 8";
        ctrl-9 = "workspace 9";
        ctrl-0 = "workspace 10";

        ctrl-shift-1 = "move-node-to-workspace 1";
        ctrl-shift-2 = "move-node-to-workspace 2";
        ctrl-shift-3 = "move-node-to-workspace 3";
        ctrl-shift-4 = "move-node-to-workspace 4";
        ctrl-shift-5 = "move-node-to-workspace 5";
        ctrl-shift-6 = "move-node-to-workspace 6";
        ctrl-shift-7 = "move-node-to-workspace 7";
        ctrl-shift-8 = "move-node-to-workspace 8";
        ctrl-shift-9 = "move-node-to-workspace 9";
        ctrl-shift-0 = "move-node-to-workspace 10";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        ctrl-shift-semicolon = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];

        down = "volume down";
        up = "volume up";
        shift-down = [
          "volume set 0"
          "mode main"
        ];
      };

      workspace-to-monitor-force-assignment = {
        "9" = "secondary";
        "10" = "secondary";
      };
    };
  };
}
