{ pkgs, ... }:

let
  # The 1Password desktop app writes this manifest into
  # ~/.mozilla/native-messaging-hosts by itself, the first time the browser
  # integration is switched on. Enabling the module below makes Home Manager
  # own that directory, so the app's own copy would be moved aside on the next
  # activation and the extension would lose the app it unlocks against.
  # Declaring it keeps the integration working, and brings it up from an empty
  # home as well.
  onePasswordMessagingHost = pkgs.writeTextFile {
    name = "1password-firefox-native-messaging-host";
    destination = "/lib/mozilla/native-messaging-hosts/com.1password.1password.json";
    text = builtins.toJSON {
      name = "com.1password.1password";
      description = "1Password BrowserSupport";
      # The setuid wrapper that programs._1password-gui in
      # ../modules/desktop.nix installs.
      path = "/run/wrappers/bin/1Password-BrowserSupport";
      type = "stdio";
      # The extension ids 1Password ships: release, beta and nightly.
      allowed_extensions = [
        "{0a75d802-9aed-41e7-8daa-24c067386e82}"
        "{25fc87fa-4d31-4fee-b5c1-c32a7844c063}"
        "{d634138d-c276-4fc8-924b-40a0ea21d284}"
      ];
    };
  };
in

# Firefox through the Home Manager module rather than as a bare package in
# ./packages.nix. The module writes user.js, which Firefox reads at every
# start and which overrides prefs.js, so what is declared here is what the
# browser runs with. Anything not listed stays ordinary profile state.
{
  programs.firefox = {
    enable = true;

    # Firefox stores its profile under $XDG_CONFIG_HOME when ~/.mozilla/firefox
    # does not exist, which is the case here, and that is where this profile
    # already lives. The module still defaults to the legacy ~/.mozilla/firefox
    # below stateVersion 26.05, so the path is named explicitly; it is also
    # handed to the wrapper as appDataDir, which pins the location rather than
    # leaving it to Firefox's own probing.
    #
    # Relative to the home directory, like the module's own default: the file
    # targets it derives from this are resolved against $HOME, so an absolute
    # path here would have Home Manager write to $HOME/home/mael/...
    configPath = ".config/mozilla/firefox";

    nativeMessagingHosts = [ onePasswordMessagingHost ];

    # Enterprise policies, read from the wrapper rather than from the profile.
    # What can be expressed here is enforced whatever a profile contains, so
    # the switches that must not drift live here and the rest are preferences.
    policies = {
      # The three extensions already installed, reinstalled from AMO on a
      # fresh profile and kept up to date by Firefox itself. force_installed
      # also means they cannot be removed from about:addons: removing one is
      # an edit to this file.
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
        # The desktop app it talks to comes from programs._1password-gui in
        # ../modules/desktop.nix, and the native messaging host it needs is
        # already installed for this account.
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };

      # 1Password holds the passwords, so Firefox's own manager is off rather
      # than merely unused: two stores asking to save the same login is how
      # credentials end up in the one that is not backed up.
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;

      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;

      # The default browser is set by xdg.mimeApps in ./xdg.nix, so the prompt
      # has nothing to fix.
      DontCheckDefaultBrowser = true;
    };

    profiles.default = {
      id = 0;

      # The profile that already exists. Bookmarks, cookies, history and the
      # signed-in session live in it, and a different name here would leave
      # them behind in favour of an empty profile.
      path = "6wdcg3b6.default";

      # Firefox 145 and later also keep profile metadata in a SQLite store
      # named after this id, under "Profile Groups". Repeating the existing
      # one keeps profiles.ini and that store pointing at the same profile.
      storeId = "90578d59";

      isDefault = true;

      settings = {
        # --- Carried over from the profile ---

        # Speculative connections open sockets to hosts that were never
        # visited, on hover and on typing in the address bar. Already set in
        # this profile; kept, because it is the one group of prefs here that
        # changes what leaves the machine before any click.
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.http.speculative-parallel-limit" = 0;

        # French pages are read as they are, so the translation bar stays shut.
        "browser.translations.neverTranslateLanguages" = "fr";

        # The sidebar closes with the panel instead of keeping its strip.
        "sidebar.visibility" = "hide-on-close";

        # The toolbar as it is arranged today: uBlock and 1Password next to the
        # address bar, SponsorBlock folded into the extensions panel. Written
        # as an attribute set because the module encodes a non-scalar value as
        # the JSON string this pref expects.
        #
        # This is the one pref worth dropping if it gets in the way: Firefox
        # bumps currentVersion when it adds a default button, and pinning an
        # older layout means new buttons do not appear on their own.
        "browser.uiCustomization.state" = {
          placements = {
            widget-overflow-fixed-list = [ ];
            unified-extensions-area = [ "sponsorblocker_ajay_app-browser-action" ];
            nav-bar = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "customizableui-special-spring1"
              "vertical-spacer"
              "urlbar-container"
              "customizableui-special-spring2"
              "downloads-button"
              "fxa-toolbar-menu-button"
              "reset-pbm-toolbar-button"
              "unified-extensions-button"
              "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
              "ublock0_raymondhill_net-browser-action"
            ];
            toolbar-menubar = [ "menubar-items" ];
            TabsToolbar = [
              "tabbrowser-tabs"
              "new-tab-button"
              "customizableui-special-spring3"
              "alltabs-button"
              "smartwindow-group-tabs-button"
              "ai-window-toggle"
            ];
            vertical-tabs = [ ];
            PersonalToolbar = [ "personal-bookmarks" ];
          };
          seen = [
            "reset-pbm-toolbar-button"
            "smartwindow-group-tabs-button"
            "ai-window-toggle"
            "developer-button"
            "screenshot-button"
            "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "sponsorblocker_ajay_app-browser-action"
          ];
          dirtyAreaCache = [
            "nav-bar"
            "TabsToolbar"
            "vertical-tabs"
            "PersonalToolbar"
            "toolbar-menubar"
            "unified-extensions-area"
          ];
          currentVersion = 26;
          newElementCount = 3;
        };

        # --- Telemetry and experiments ---
        #
        # DisableTelemetry above already covers the upload. These turn off the
        # collection itself, so nothing is measured and stored locally either,
        # and they keep working if the policy ever stops being applied.
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.coverage.opt-out" = true;
        "browser.ping-centre.telemetry" = false;

        # Normandy ships remote configuration changes and enrols the profile in
        # studies without asking each time.
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "app.shield.optoutstudies.enabled" = false;

        "browser.tabs.crashReporting.sendReport" = false;

        # --- Sponsored content ---
        #
        # The new tab page and the address bar both carry paid placements,
        # which are what the blocked-sponsor list in this profile was fighting
        # one tile at a time.
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

        # --- Security ---

        # Upgrade every navigation to HTTPS and show an interstitial rather
        # than silently falling back. A site that is genuinely HTTP-only still
        # loads, behind one click.
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;

        # The opt-out signal sites are legally required to honour in several
        # jurisdictions, unlike the older Do Not Track header.
        "privacy.globalprivacycontrol.enabled" = true;

        # Enhanced Tracking Protection at strict instead of standard: it also
        # blocks cross-site cookies everywhere, known fingerprinters and
        # cryptominers. This is the setting here most likely to break a page -
        # usually a third-party login or an embedded payment frame - and the
        # shield icon in the address bar disables it per site.
        "browser.contentblocking.category" = "strict";

        # --- Hardware ---

        # VA-API decoding on the Iris Xe, whose driver comes from
        # ../modules/laptop.nix. Video decoded on the GPU rather than on the
        # CPU is the difference between a warm laptop and a quiet one.
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };
}
