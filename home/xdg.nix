_:

# User directories and the default application for each file type.
{
  xdg = {
    userDirs = {
      enable = true;
      setSessionVariables = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        # VS Code also claims directories, so without this it can win over Thunar.
        "inode/directory" = "thunar.desktop";
        # Chromium is installed for Playwright; keep it from becoming the browser.
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        # Firefox's built-in viewer: fast to open, and it only views.
        "application/pdf" = "firefox.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
        "application/x-rar" = "org.gnome.FileRoller.desktop";
        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";
        "video/mp4" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "video/x-msvideo" = "vlc.desktop";
        "video/mpeg" = "vlc.desktop";
        "video/ogg" = "vlc.desktop";
        "video/mp2t" = "vlc.desktop";
        "video/x-flv" = "vlc.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
      };
    };
    configFile."mimeapps.list".force = true;
  };
}
