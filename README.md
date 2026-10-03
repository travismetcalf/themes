# Themes

A shared collection of application themes derived from the design language at `travismetcalf.com/styleguide`.

## Structure

```text
palettes/          Canonical, application-neutral color tokens
apps/<app>/        Application-specific theme adapters
scripts/           Installation helpers
```

## Included palettes

- **Dusk** — deep navy-purple surfaces, lavender-white ink, crimson emphasis, and editorial gold.
- **Cream** — warm cream surfaces, deep navy ink, darkened crimson, and text-safe gold.
- **Linear** — layered near-black surfaces, cool neutral ink, and focused indigo accents.

## Hermes

Hermes skins are in [`apps/hermes`](apps/hermes).

Install all three skins:

```bash
./scripts/install-hermes.sh
```

Install into a specific Hermes profile or home:

```bash
HERMES_HOME="$HOME/.hermes/profiles/example" ./scripts/install-hermes.sh
```

The installer overwrites matching runtime skins. Compare and back up any local customizations before running it.

Activate a skin:

```bash
hermes config set display.skin dusk
# or
hermes config set display.skin cream
# or
hermes config set display.skin linear
```

Return to the default skin:

```bash
hermes config set display.skin default
```

## Deployment and Layout

**Source Layout**

- Laptop: `~/projects/themes`
- travis-mac: `~/projects/themes` on the host, `/projects/themes` in Docker.
- Local preservation: `.local-drafts/2026-10-03` is ignored local state (mac only), not tracked source.

**Runtime State**

- Default: `~/.hermes/skins`
- Custom: `HERMES_HOME` profile paths.
- Note: `~/deploy/themes` is not needed until automated runtime deployment is designed.

**Workflow**

- Future: `themes_fetch_main` / `themes_publish_branch` with `hermes/*` branch naming.
- Current: Use laptop PR publication.
- Security: Never use `gh auth login` or service-account tokens in the sandbox.

## Source of truth

The files under `palettes/` describe the reusable design tokens. Files under `apps/` map those tokens to each application's theme schema.
