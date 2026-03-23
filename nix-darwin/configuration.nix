{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [

  ];

  system.primaryUser = "earlgray";

  # macOS system defaults
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # Enable dark mode
      AppleSpacesSwitchOnActivate = false; # Don't switch Spaces when activating apps
      InitialKeyRepeat = 15; # Delay before key repeat starts (lower = faster)
      KeyRepeat = 2; # Key repeat speed (lower = faster, 2 = fastest, 120 = slowest)
      NSAutomaticCapitalizationEnabled = false; # Disable automatic capitalization
      NSAutomaticPeriodSubstitutionEnabled = false; # Disable automatic period substitution
      "com.apple.sound.beep.volume" = 0.0; # Mute alert sounds
      "com.apple.springing.delay" = 0.5; # Spring-loading delay (seconds)
      "com.apple.springing.enabled" = true; # Enable spring-loading for directories
      "com.apple.trackpad.forceClick" = true; # Enable Force Touch / haptic feedback
      "com.apple.trackpad.scaling" = 2.0; # Trackpad tracking speed
    };

    dock = {
      autohide = true; # Automatically hide and show the Dock
      launchanim = false; # Disable launch animation when opening apps
      mineffect = "scale"; # Minimize window effect: "genie", "scale", or "suck"
      mru-spaces = false; # Don't automatically rearrange Spaces based on most recent use
      show-recents = false; # Don't show recent applications in Dock
      tilesize = 39; # Size of the icons in the Dock
      wvous-br-corner = 14; # Bottom-right hot corner: Quick Note
    };

    finder = {
      AppleShowAllExtensions = true; # Show all file extensions
      FXDefaultSearchScope = "PfAF"; # Default search scope: all files
      FXEnableExtensionChangeWarning = false; # Disable warning when changing file extension
      FXPreferredViewStyle = "Nlsv"; # Default view style: "icnv" (icon), "Nlsv" (list), "clmv" (column), "Flwv" (gallery)
      ShowPathbar = true; # Show path bar at bottom of Finder windows
      ShowStatusBar = false; # Hide status bar at bottom of Finder windows
      _FXShowPosixPathInTitle = true; # Show full POSIX path in Finder title bar
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        "com.apple.keyboard.fnState" = true; # Use F1, F2, etc. as standard function keys
        "com.apple.sound.uiaudio.enabled" = 0; # Disable UI sounds
      };
      "com.apple.menuextra.clock" = {
        ShowAMPM = true; # Show AM/PM indicator
        ShowDate = 0; # Hide date (0 = off)
        ShowDayOfWeek = true; # Show day of week
      };
    };
  };

  # Homebrew integration
  homebrew = {
    enable = true;

    taps = [
      "felixkratz/formulae" # for borders
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
      "android-studio"
      "insta360-studio"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
  };

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
