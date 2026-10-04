# Codex desktop themes

Import a theme by opening **Codex → Settings → Appearance**, choosing the matching variant, then pasting the one-line string from the corresponding `.codex-theme` file into the theme import field.

Theme files in this directory are generated from the canonical palettes in `palettes/` by `scripts/build-codex-themes.rb`.

| Theme | Variant | Surface | Ink | Accent | Diff added | Diff removed | Skill |
|---|---|---:|---:|---:|---:|---:|---:|
| `dusk` | dark | #0f1020 | #ece9f5 | #e0485f | #55c96f | #e65e73 | #d8b25a |
| `cream` | light | #f4f1ea | #1a1b2e | #a8182f | #106b0c | #a8182f | #806017 |
| `linear` | dark | #08090a | #f7f8f8 | #7170ff | #27a644 | #eb5757 | #4ea7fc |

## Restore a previous theme

1. Open **Codex → Settings → Appearance**.
2. Use the theme export or share control to copy the current theme string.
3. Save that string outside the repository.
4. To restore the previous theme later, paste the saved string back into the theme import field.

## Contrast

WCAG 2.1 contrast ratios against each theme’s primary surface are shown below. Normal text targets 4.5:1; large text and UI components target 3:1.

| Theme | Ink | Accent | Diff added | Diff removed | Skill |
|---|---:|---:|---:|---:|---:|
| `dusk` | 15.73 | 4.72 | 8.94 | 5.57 | 9.36 |
| `cream` | 15.01 | 6.56 | 5.95 | 6.56 | 5.17 |
| `linear` | 18.73 | 5.18 | 6.29 | 5.73 | 7.84 |
