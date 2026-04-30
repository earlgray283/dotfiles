{ ... }:

{
  # Ghostty terminal emulator
  # Note: No nix package for macOS (distributed as App Bundle); install via official DMG
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "Catppuccin Frappe";
      shell-integration = "zsh";

      font-family = [
        "JetBrainsMonoNL Nerd Font Mono"
        "Hiragino Kaku Gothic ProN"
      ];
      font-size = 12;
      font-feature = [ "-dlig" ];
      font-thicken = true;
      font-thicken-strength = 100;
      adjust-cell-width = "-5%";
      adjust-cell-height = "10%";

      keybind = [
        "global:cmd+grave_accent=toggle_quick_terminal"
        "shift+enter=text:\\n"
      ];
      quick-terminal-animation-duration = 0;

      mouse-scroll-multiplier = 0.5;
      link-url = true;
      confirm-close-surface = false;
    };
  };
}
