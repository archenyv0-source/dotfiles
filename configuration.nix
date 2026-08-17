{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click

    # App preferences that have no dedicated nix-darwin option.
    CustomUserPreferences = {
      # OpenSuperWhisper: toggle dictation with Cmd+/ instead of the stock
      # Option+backtick.
      #
      # modifierOnlyHotkey must stay "none": any other value makes the app
      # watch for a bare modifier press and ignore the shortcut below.
      # That mode also fires on ANY press of the chosen key, so binding it
      # to a real modifier breaks that key for ordinary use.
      #
      # Caveat on a fresh machine: OnboardingViewModel.init overwrites
      # "none" with "rightOption" whenever hasCompletedOnboarding is still
      # false, so this setting only sticks once onboarding has been
      # finished. Pick the "key combination" option there, not Right
      # Option, or the app keeps ignoring the shortcut below.
      #
      # The shortcut cannot be pinned to the *right* Command key. The app
      # encodes modifiers through NSEvent.ModifierFlags, which has no
      # left/right distinction, so either Command key triggers it.
      #
      # The value is what the KeyboardShortcuts library persists: a JSON
      # string under "KeyboardShortcuts_<name>". 44 is kVK_ANSI_Slash and
      # 256 is cmdKey (1 << cmdKeyBit), both from Carbon Events.h.
      "ru.starmel.OpenSuperWhisper" = {
        modifierOnlyHotkey = "none";
        KeyboardShortcuts_toggleRecord = builtins.toJSON {
          carbonKeyCode = 44;
          carbonModifiers = 256;
        };
      };
    };
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    # This Mac already had a hand-installed Homebrew in /opt/homebrew. Let
    # nix-homebrew take that prefix over on the first switch, keeping the
    # packages already installed there.
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # "zap" remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
      "hermes-agent"
      "node"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "codex"
      "devin-desktop"
      "opensuperwhisper"
    ];
  };
}
