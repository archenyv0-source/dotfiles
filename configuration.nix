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
      # OpenSuperWhisper: toggle dictation with Right Command on its own,
      # instead of the stock Option+backtick. This is a "modifier-only"
      # hotkey, and the app fires it on ANY press of that key, with no
      # check for other keys held down. So Right Command stops working as
      # an ordinary modifier: right-handed Cmd-C or Cmd-Tab will start
      # recording. Pick a modifier you never otherwise press, or switch
      # back to a regular shortcut in the app's settings.
      # Valid values: none, leftCommand, rightCommand, leftOption,
      # rightOption, leftShift, rightShift, leftControl, rightControl, fn.
      "ru.starmel.OpenSuperWhisper" = {
        modifierOnlyHotkey = "rightCommand";
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
