# Agent Instructions

- Always write in English.
- All user-facing text, documentation, comments, log messages, notifications, labels, and configuration descriptions must be in English.
- Keep proper names unchanged, including `Mael` and `Maël`.
- Preserve the existing technical behavior and make focused changes.

## Nix and NixOS Practices

- Keep `flake.nix` and `flake.lock` reproducible; do not use channels or ad-hoc
	package installation for configuration-managed software.
- Pin external inputs through the flake lock file and update them deliberately
	with `nix flake update`.
- Prefer existing NixOS and Home Manager modules over custom shell glue.
- Keep system-wide packages in NixOS modules and user applications in Home
	Manager unless there is a clear reason to do otherwise.
- Prefer explicit package references and narrowly scoped
	`allowUnfreePredicate` entries over globally allowing unfree packages.
- Keep host-specific settings in `hosts/<name>/` and shared settings in
	`modules/` or `home/`.
- Use current option names and migrate deprecated options when validation warns
	about renamed or obsolete settings.
- Make services declarative and idempotent; avoid manually launched background
	processes when a systemd or Home Manager service is available.
- Keep secrets, private keys, tokens, passwords, and machine-specific secrets
	out of the repository.
- Validate changes with `nix flake check --no-build` and, when appropriate,
	evaluate or build the affected host configuration before applying it.
- Keep new files tracked by Git when they are referenced by a flake, because
	Git-backed flake evaluation ignores untracked source files.
- Use `nix fmt` or the repository formatter when one is configured, and avoid
	unrelated formatting or refactoring.
