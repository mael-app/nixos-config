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
  security.pam.howdy.enable = false;
  security.pam.services.hyprlock.howdy.enable = true;

  # Ask for the password first and only start the camera when it is wrong. The
  # default stack puts howdy before pam_unix; move it just after, so a correct
  # password succeeds and stops before the camera runs, and a wrong one falls
  # through to the face check.
  security.pam.services.hyprlock.rules.auth.howdy.order =
    config.security.pam.services.hyprlock.rules.auth.unix.order + 10;
}
