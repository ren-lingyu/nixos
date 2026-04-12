{ config, lib, pkgs, ... } : let

  keepassxcSettings = {
    General = {
      SingleInstance = false;
      RememberLastDatabases = false;
      RememberLastKeyFiles = false;
      OpenPreviousDatabasesOnStartup = false;
      AutoSaveAfterEveryChange = false;
      AutoSaveOnExit = false;
      AutoReloadOnChange = true;
      AutoTypeEntryTitleMatch = true;
      AutoTypeEntryURLMatch = true;
      UpdateCheckMessageShown = false;
    };
    Browser = {
      Enabled = true;
      UnlockDatabase = true;
      BestMatchOnly = true;
      SearchInAllDatabases = false;
      AlwaysAllowAccess = false;
      AlwaysAllowUpdate = false;
    };
    GUI = {
      Language = "zh_CN";
      AdvancedSettings = true;
      ApplicationTheme = "dark";
      CompactMode = true;
      HidePasswords = true;
      ShowTrayIcon = false;
      MinimizeToTray = false;
      MinimizeOnClose = true;
      CheckForUpdates = false;
    };
    SSHAgent.Enabled = true;
    Security = {
      ClearClipboard = true;
      ClearClipboardTimeout = 10;
      LockDatabaseScreenLock = true;
      LockDatabaseMinimize = false;
      LockDatabaseIdle = false;
    };
    PasswordGenerator = {
      Length = 20;
      UpperCase = true;
      LowerCase = true;
      Numbers = true;
      SpecialChars = true;
      ExcludeAlike = true;
    };
  };

in {

  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
  };
  
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
    enableZshIntegration = true;
    grabKeyboardAndMouse = true;
    enableSshSupport = false;
  };
  
  programs.keepassxc = {
    enable = true;
    package = pkgs.keepassxc;
    autostart = true;
    # settings = keepassxcSettings;
  };

  programs.git-credential-keepassxc = {
    enable = true;
    package = pkgs.git-credential-keepassxc;
    # hosts = [ "github.com" ];
    groups = [ "Git" ];
  };

}
