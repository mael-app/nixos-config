{ config, ... }:

{
  services.howdy = {
    enable = true;
    # Howdy is a fallback, not the primary check: "sufficient" only short
    # circuits on success, so a failed face match still falls through to the
    # password prompt.
    control = "sufficient";
    settings = {
      core.no_confirmation = true;
      video.device_path = "/dev/video2";
    };
  };

  # services.howdy enables the PAM module on every service by default, which
  # put it on sudo as well. Turn it off everywhere and enable it only on the
  # lock screen, so face unlock never grants root.
  security.pam = {
    howdy.enable = false;
    services.hyprlock.howdy.enable = true;
  };

  # Try face authentication first; a failed match falls through to the usual
  # password prompt. Keeping Howdy before pam_unix also avoids relying on the
  # password module's failure path to invoke the camera.
  security.pam.services.hyprlock.rules.auth.howdy.order =
    config.security.pam.services.hyprlock.rules.auth.unix.order - 10;
}
