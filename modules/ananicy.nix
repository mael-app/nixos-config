{ pkgs, ... }:

# Ananicy-cpp renices applications as they are identified by rule: IDE
# indexers, compilers, backup agents and the like drop to a lower CPU
# priority instead of stealing cycles from whatever is in the foreground.
# Nothing is frozen, background work just yields. This is the NixOS
# counterpart of the scheduler daemon Pop!_OS ships, and it composes with
# sched_ext (./scx.nix), whose scheduler still honours nice values.
#
# Both the package and the rules are pinned to ananicy-cpp: the module
# defaults to the original ananicy, whose rules were written for it rather
# than for the rewritten daemon.
{
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp;
  };
}
