{ config, pkgs, inputs, ... }:

{
  # Use Lix instead of Nix
  nix.package = pkgs.lix;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    
  ];

  system.primaryUser = "earlgray";

  # macOS system defaults
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";  # Enable dark mode
      KeyRepeat = 2;  # Key repeat speed (lower = faster, 2 = fastest, 120 = slowest)
      InitialKeyRepeat = 15;  # Delay before key repeat starts (lower = faster)
      NSAutomaticCapitalizationEnabled = false;  # Disable automatic capitalization
      NSAutomaticPeriodSubstitutionEnabled = false;  # Disable automatic period substitution
    };

    dock = {
      autohide = true;  # Automatically hide and show the Dock
      tilesize = 39;  # Size of the icons in the Dock
      launchanim = false;  # Disable launch animation when opening apps
      mineffect = "scale";  # Minimize window effect: "genie", "scale", or "suck"
      show-recents = false;  # Don't show recent applications in Dock
      mru-spaces = false;  # Don't automatically rearrange Spaces based on most recent use
    };

    finder = {
      FXPreferredViewStyle = "Nlsv";  # Default view style: "icnv" (icon), "Nlsv" (list), "clmv" (column), "Flwv" (gallery)
      AppleShowAllExtensions = true;  # Show all file extensions
      ShowPathbar = true;  # Show path bar at bottom of Finder windows
      FXEnableExtensionChangeWarning = false;  # Disable warning when changing file extension
    };
  };

  # Homebrew integration
  homebrew = {
    enable = true;

    taps = [
      "felixkratz/formulae"  # for borders
      "nikitabobko/tap"      # for Aerospace
    ];

    brews = [
      "ios-deploy"
      "xcodegen"
      "felixkratz/formulae/borders"
      "openjdk"
            "cockroachdb/tap/cockroach"
    ];

    casks = [
      "1password"
      "aerospace"
      "discord"
      "firefox"
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "google-drive"
      "hot"
      "karabiner-elements"
      "orbstack"
      "slack"
      "zed"
    ];
  };

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
