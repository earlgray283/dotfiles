{ pkgs, ... }:

let
  silentSound = import ../lib/herdr.nix { inherit pkgs; };
in
{
  programs.herdr = {
    enable = true;

    settings = {
      onboarding = false;

      terminal = {
        default_shell = "${pkgs.zsh}/bin/zsh";
        shell_mode = "auto";
        new_cwd = "follow";
      };

      # herdr ships no Frappe flavor, but its custom tokens are named after the
      # Catppuccin palette, so Frappe is reachable by overriding Mocha's.
      theme = {
        name = "catppuccin";
        custom = {
          accent = "#81c8be";
          panel_bg = "#292c3c";
          surface0 = "#414559";
          surface1 = "#51576d";
          overlay0 = "#737994";
          overlay1 = "#838ba7";
          text = "#c6d0f5";
          subtext0 = "#a5adce";
          mauve = "#ca9ee6";
          green = "#a6d189";
          yellow = "#e5c890";
          red = "#e78284";
          blue = "#8caaee";
          teal = "#81c8be";
          peach = "#ef9f76";
        };
      };

      ui = {
        sidebar_width = 22;

        # One line per space instead of the default icon+name / branch+status
        # stack, which halves the list height. Agents keep their two-row layout.
        sidebar.spaces.rows = [
          [
            "state_icon"
            "workspace"
            "branch"
            "git_status"
          ]
        ];

        # In-app toasts rather than "system": the Claude Code and opencode
        # notification hooks already own the macOS notification centre, and
        # herdr suppresses toasts for the focused tab anyway.
        toast = {
          delivery = "herdr";
          delay_seconds = 1;
          herdr.position = "bottom-right";
        };

        sound.done_path = "${silentSound}";
      };

      keys = {
        prefix = "ctrl+a";
        split_vertical = [
          "prefix+|"
          "prefix+pipe"
          "prefix+bar"
          "prefix+shift+backslash"
          "prefix+backslash"
          "prefix+v"
        ];
        split_horizontal = [ "prefix+minus" ];
        detach = [
          "prefix+d"
          "prefix+q"
        ];
      };
    };
  };
}
