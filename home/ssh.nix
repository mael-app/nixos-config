{ ... }:

# The SSH client and the agent that carries the key for the session, so the
# private key can stay encrypted on disk without asking for the passphrase on
# every push and every signed commit.
{
  programs.ssh = {
    enable = true;

    # The implicit defaults this module still ships warn on every activation
    # and only restate OpenSSH's own, so nothing is lost by turning them off.
    enableDefaultConfig = false;

    # Hand the key to the agent the first time it is used. The passphrase is
    # then typed once per session instead of once per connection.
    settings."*".AddKeysToAgent = "yes";
  };

  # The agent keeps the decrypted key in its own memory and exports
  # SSH_AUTH_SOCK to the shell and to the systemd user session, so git and the
  # editors find it too. git signs commits with ~/.ssh/id_ed25519.pub (see
  # ./git.nix), which OpenSSH resolves through the agent.
  services.ssh-agent.enable = true;
}
