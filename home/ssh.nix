{ config, pkgs, ... }:

let
  # SSH_ASKPASS protocol: the prompt text arrives as the first argument and
  # the passphrase is written to stdout. rofi is already part of this session
  # and already themed, and -password masks the input. The purpose built
  # dialogs all belong to a desktop environment: lxqt-openssh-askpass, the
  # usual answer, drags 780 MiB of Qt into the closure for one prompt a day.
  # stdin is closed because rofi -dmenu otherwise waits for a list to read.
  askpass = pkgs.writeShellScript "rofi-askpass" ''
    exec ${config.programs.rofi.finalPackage}/bin/rofi \
      -dmenu -password -p "SSH" -mesg "$1" < /dev/null
  '';

  # How long the agent keeps the decrypted key. Anything running as this
  # user can sign or log in with it without a prompt, so the window is
  # bounded; the timer below asks for the passphrase again when it ends.
  keyLifetime = "8h";
in

# The SSH client, the agent that carries the key for the session, and the unit
# that unlocks it once at login. Together they let the private key stay
# encrypted on disk without a passphrase prompt on every push or signed
# commit: git reads the key through the agent, which holds it decrypted in its
# own memory for keyLifetime.
{
  programs.ssh = {
    enable = true;

    # The implicit defaults this module still ships warn on every activation
    # and only restate OpenSSH's own, so nothing is lost by turning them off.
    enableDefaultConfig = false;

    # Hand the key to the agent the first time ssh itself uses it, which
    # covers the case where the session service below was cancelled.
    settings = {
      "*".AddKeysToAgent = keyLifetime;

      # The Raspberry Pi running the Minecraft server. sshd there listens on a
      # non-default port, and the alias spares typing the address, port and
      # account on every connection.
      "rpi.local" = {
        HostName = "172.29.94.35";
        Port = 22422;
        User = "root";
      };

      # IPv6 is unreachable on the current network, so avoid its connection timeout.
      "gitlab.com".AddressFamily = "inet";
    };
  };

  services.ssh-agent.enable = true;

  # Unlocking the key needs a window, so this waits for the graphical session
  # rather than starting with the agent.
  #
  # The type is left at the default: a oneshot unit wanted by a target makes
  # the target wait for it to finish, which here would hold the whole session
  # behind the passphrase prompt until it is answered.
  #
  # ssh-add only loads the key when git or ssh asks the agent for it, and
  # signing a commit never does - git reads the key through the agent but does
  # not populate it - so without this unit the first commit after a reboot
  # would fail instead of asking for anything.
  systemd.user.services.ssh-add-key = {
    Unit = {
      Description = "Unlock the SSH key for this session";
      Requires = [ "ssh-agent.service" ];
      After = [
        "ssh-agent.service"
        "graphical-session.target"
      ];
      PartOf = [ "graphical-session.target" ];
      # Nothing to unlock before the key exists, and a missing key must not
      # leave a failed unit behind.
      ConditionPathExists = "%h/.ssh/id_ed25519";
    };
    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-add -t ${keyLifetime} %h/.ssh/id_ed25519";
      Environment = [
        "SSH_ASKPASS=${askpass}"
        # Without this, ssh-add prefers a terminal it does not have here and
        # never opens the dialog.
        "SSH_ASKPASS_REQUIRE=force"
        "SSH_AUTH_SOCK=%t/${config.services.ssh-agent.socket}"
      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # The agent drops the key after keyLifetime, and a signed commit cannot
  # load it back by itself (see above). Run the unlock again at that moment,
  # so the passphrase prompt appears instead of the next commit failing.
  systemd.user.timers.ssh-add-key = {
    Unit = {
      Description = "Unlock the SSH key again when the agent drops it";
      PartOf = [ "graphical-session.target" ];
    };
    Timer.OnUnitActiveSec = keyLifetime;
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
