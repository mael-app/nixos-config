# Agent Instructions

## Language

- Everything that lands in this repository is written in English: Nix code,
	comments, option descriptions, documentation, commit messages, pull request
	descriptions, script output, and every user-facing string the configuration
	produces. This holds whatever language the request was written in.
- Replies in a conversation are not repository content. Answer in the language
	the user is writing in, and follow them when they switch.
- Keep proper names unchanged, including `Mael` and `Maël`.

## Working Style

- Preserve the existing technical behavior and make focused changes.
- Validate changes with `nix flake check --no-build` and, when appropriate,
	evaluate or build the affected host configuration before applying it.
- Run `nix fmt` before committing. The formatter is `nixfmt-tree`, so it takes
	the whole repository; `nix fmt -- --ci` checks it without keeping the
	result. Avoid unrelated refactoring.
- Keep new files tracked by Git when they are referenced by a flake, because
	Git-backed flake evaluation ignores untracked source files.

## Nix and NixOS Practices

- Keep `flake.nix` and `flake.lock` reproducible; do not use channels or ad-hoc
	package installation for configuration-managed software.
- Pin external inputs through the flake lock file and update them deliberately
	with `nix flake update`.
- Prefer existing NixOS and Home Manager modules over custom shell glue.
- Keep system-wide packages in NixOS modules and user applications in Home
	Manager unless there is a clear reason to do otherwise. A package that only
	the desktop account runs belongs in `home/`; the NixOS modules carry what the
	system, a service, or another user needs.
- Keep one subject per file in `modules/` and `home/`, and add it to the
	relevant `imports` list rather than growing an existing file.
- Take the account name from the `username` argument rather than writing it
	out; `flake.nix` passes it, along with `host`, to every module.
- Prefer explicit package references and narrowly scoped
	`allowUnfreePredicate` entries over globally allowing unfree packages.
- Keep host-specific settings in `hosts/<name>/` and shared settings in
	`modules/` or `home/`. When a shared setting only differs by a value, declare
	an option for it rather than duplicating the setting per host.
- Use current option names and migrate deprecated options when validation warns
	about renamed or obsolete settings.
- Make services declarative and idempotent; avoid manually launched background
	processes when a systemd or Home Manager service is available. In particular,
	do not autostart daemons from the Hyprland configuration.
- Keep secrets, private keys, tokens, passwords, and machine-specific secrets
	out of the repository.
