# Themes

Reusable color palettes and application themes, with adapters for Hermes.

## Included palettes

- **Dusk** — deep navy-purple surfaces, lavender-white ink, crimson emphasis, and editorial gold.
- **Cream** — warm cream surfaces, deep navy ink, darkened crimson, and text-safe gold.
- **Linear** — layered near-black surfaces, cool neutral ink, and focused indigo accents.

## Hermes

Hermes skins are in [`apps/hermes`](apps/hermes). These adapters require a Hermes installation that supports custom YAML skins and the `display.skin` setting.

### Install

Clone the repository and install all three skins:

```bash
git clone https://github.com/travismetcalf/themes.git
cd themes
./scripts/install-hermes.sh
```

The installer copies the skins into `${HERMES_HOME:-$HOME/.hermes}/skins`. It does not activate a skin or install Hermes itself.

**The installer overwrites matching skin files.** Compare and back up any local customizations before running it.

To install into a specific Hermes profile or home, run this from the repository directory:

```bash
HERMES_HOME="$HOME/.hermes/profiles/example" ./scripts/install-hermes.sh
```

### Activate

Run one of these commands in the Hermes profile where you installed the skins:

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

## Repository structure

```text
palettes/          Canonical, application-neutral color tokens
apps/<app>/        Application-specific theme adapters
scripts/           Installation helpers
```

The files under `palettes/` are the source of truth for reusable design tokens. Files under `apps/` map those tokens to each application's theme schema.

## License

[MIT](LICENSE).
