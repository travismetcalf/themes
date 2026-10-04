#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"

PALETTE_FILES = {
  "dusk" => "palettes/dusk.yaml",
  "cream" => "palettes/cream.yaml",
  "linear" => "palettes/linear.yaml"
}.freeze

MAPPINGS = {
  "dusk" => {
    "surface" => "paper",
    "ink" => "ink",
    "accent" => "accent_text",
    "diff_added" => "good",
    "diff_removed" => "bad",
    "skill" => "gold"
  }.freeze,
  "cream" => {
    "surface" => "paper",
    "ink" => "ink",
    "accent" => "accent",
    "diff_added" => "good",
    "diff_removed" => "bad",
    "skill" => "gold"
  }.freeze,
  "linear" => {
    "surface" => "paper",
    "ink" => "ink",
    "accent" => "accent_text",
    "diff_added" => "green",
    "diff_removed" => "red",
    "skill" => "blue"
  }.freeze
}.freeze

VARIANT = {
  "dusk" => "dark",
  "cream" => "light",
  "linear" => "dark"
}.freeze

CONTRAST = {
  "dusk" => 60,
  "cream" => 45,
  "linear" => 60
}.freeze

def hex_to_rgb(value)
  value = value.delete("#")
  [0, 2, 4].map { |i| value[i, 2].to_i(16) }
end

def relative_luminance(rgb)
  rgb.map do |component|
    c = component / 255.0
    c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
  end.then { |r, g, b| 0.2126 * r + 0.7152 * g + 0.0722 * b }
end

def contrast_ratio(a, b)
  l1 = relative_luminance(hex_to_rgb(a))
  l2 = relative_luminance(hex_to_rgb(b))
  lighter = [l1, l2].max
  darker = [l1, l2].min
  ((lighter + 0.05) / (darker + 0.05)).round(2)
end

def build_theme(name, palette)
  colors = palette.fetch("colors")
  mapping = MAPPINGS.fetch(name)
  variant = VARIANT.fetch(name)

  {
    "codeThemeId" => "codex",
    "variant" => variant,
    "theme" => {
      "accent" => colors.fetch(mapping.fetch("accent")),
      "accentSource" => "custom",
      "contrast" => CONTRAST.fetch(name),
      "fonts" => {
        "code" => nil,
        "ui" => nil
      },
      "ink" => colors.fetch(mapping.fetch("ink")),
      "opaqueWindows" => false,
      "semanticColors" => {
        "diffAdded" => colors.fetch(mapping.fetch("diff_added")),
        "diffRemoved" => colors.fetch(mapping.fetch("diff_removed")),
        "skill" => colors.fetch(mapping.fetch("skill"))
      },
      "surface" => colors.fetch(mapping.fetch("surface"))
    }
  }
end

def contrast_rows(name, palette, theme)
  colors = palette.fetch("colors")
  mapping = MAPPINGS.fetch(name)
  surface = colors.fetch(mapping.fetch("surface"))
  theme_colors = theme.fetch("theme")
  {
    "ink" => contrast_ratio(surface, theme_colors.fetch("ink")),
    "accent" => contrast_ratio(surface, theme_colors.fetch("accent")),
    "diffAdded" => contrast_ratio(surface, theme_colors.fetch("semanticColors").fetch("diffAdded")),
    "diffRemoved" => contrast_ratio(surface, theme_colors.fetch("semanticColors").fetch("diffRemoved")),
    "skill" => contrast_ratio(surface, theme_colors.fetch("semanticColors").fetch("skill"))
  }
end

def validate_theme(name, theme, ratios)
  expected_keys = %w[accent accentSource contrast fonts ink opaqueWindows semanticColors surface].sort
  actual_keys = theme.fetch("theme").keys.sort
  raise "#{name}: unexpected Codex theme keys: #{actual_keys.inspect}" unless actual_keys == expected_keys
  raise "#{name}: variant must be light or dark" unless %w[light dark].include?(theme.fetch("variant"))
  ratios.each do |token, ratio|
    raise "#{name}: #{token} contrast is #{ratio}:1; minimum is 4.5:1" if ratio < 4.5
  end
end

results = []
PALETTE_FILES.each do |name, path|
  palette = YAML.load_file(path)
  theme = build_theme(name, palette)
  ratios = contrast_rows(name, palette, theme)
  validate_theme(name, theme, ratios)
  results << { "name" => name, "theme" => theme, "contrast" => ratios }
end

results.each do |result|
  name = result.fetch("name")
  theme = result.fetch("theme")
  File.write("apps/codex/#{name}.codex-theme", "codex-theme-v1:#{JSON.generate(theme)}\n")
end

File.open("apps/codex/README.md", "w") do |file|
  file.puts "# Codex desktop themes"
  file.puts
  file.puts "Import a theme by opening **Codex → Settings → Appearance**, choosing the matching variant, then pasting the one-line string from the corresponding `.codex-theme` file into the theme import field."
  file.puts
  file.puts "Theme files in this directory are generated from the canonical palettes in `palettes/` by `scripts/build-codex-themes.rb`."
  file.puts
  file.puts "| Theme | Variant | Surface | Ink | Accent | Diff added | Diff removed | Skill |"
  file.puts "|---|---|---:|---:|---:|---:|---:|---:|"
  results.each do |result|
    name = result.fetch("name")
    theme = result.fetch("theme").fetch("theme")
    file.puts(
      [
        "`#{name}`",
        result.fetch("theme").fetch("variant"),
        theme.fetch("surface"),
        theme.fetch("ink"),
        theme.fetch("accent"),
        theme.fetch("semanticColors").fetch("diffAdded"),
        theme.fetch("semanticColors").fetch("diffRemoved"),
        theme.fetch("semanticColors").fetch("skill")
      ].join(" | ").then { |row| "| #{row} |" }
    )
  end
  file.puts
  file.puts "## Restore a previous theme"
  file.puts
  file.puts "1. Open **Codex → Settings → Appearance**."
  file.puts "2. Use the theme export or share control to copy the current theme string."
  file.puts "3. Save that string outside the repository."
  file.puts "4. To restore the previous theme later, paste the saved string back into the theme import field."
  file.puts
  file.puts "## Contrast"
  file.puts
  file.puts "WCAG 2.1 contrast ratios against each theme’s primary surface are shown below. Normal text targets 4.5:1; large text and UI components target 3:1."
  file.puts
  file.puts "| Theme | Ink | Accent | Diff added | Diff removed | Skill |"
  file.puts "|---|---:|---:|---:|---:|---:|"
  results.each do |result|
    ratios = result.fetch("contrast")
    file.puts(
      [
        "`#{result.fetch('name')}`",
        ratios.fetch("ink"),
        ratios.fetch("accent"),
        ratios.fetch("diffAdded"),
        ratios.fetch("diffRemoved"),
        ratios.fetch("skill")
      ].join(" | ").then { |row| "| #{row} |" }
    )
  end
end

# The preview fragment is intentionally generated into the local visualization
# workspace, not the repository, because it is conversation-only.
preview_root = ENV.fetch("CODEX_PREVIEW_ROOT", nil)
if preview_root
  File.open(File.join(preview_root, "codex-theme-preview.html"), "w") do |file|
    file.puts '<div id="codex-theme-preview" style="display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:20px;">'
    results.each do |result|
      name = result.fetch("name")
      outer = result.fetch("theme").fetch("theme")
      surface = outer.fetch("surface")
      ink = outer.fetch("ink")
      accent = outer.fetch("accent")
      muted = result.fetch("theme").fetch("variant") == "light" ? "#4a4763" : "#8a8f98"
      inset = result.fetch("theme").fetch("variant") == "light" ? "#ffffff" : "#14152a"
      border = result.fetch("theme").fetch("variant") == "light" ? "#e0dbd0" : "#272844"
      diff_added = outer.fetch("semanticColors").fetch("diffAdded")
      diff_removed = outer.fetch("semanticColors").fetch("diffRemoved")
      file.puts "  <section aria-label=\"#{name} theme preview\" style=\"border-radius:14px; background:#{surface}; color:#{ink}; overflow:hidden;\">"
      file.puts "    <div style=\"display:flex; align-items:center; gap:10px; padding:12px 14px; background:#{inset}; border-bottom:1px solid #{border};\">"
      file.puts "      <span style=\"width:10px; height:10px; border-radius:50%; background:#{accent};\"></span>"
      file.puts "      <strong style=\"font-size:13px;\">#{name.capitalize}</strong>"
      file.puts "      <span style=\"margin-left:auto; font-size:11px; color:#{muted};\">#{result.fetch('contrast').fetch('ink')}:1</span>"
      file.puts "    </div>"
      file.puts "    <div style=\"padding:14px; font:12px/1.6 system-ui;\">"
      file.puts "      <p style=\"margin:0 0 12px; color:#{muted};\">Workspace surface</p>"
      file.puts "      <p style=\"margin:0 0 12px; color:#{ink};\">Primary text remains readable on #{name}.</p>"
      file.puts "      <p style=\"margin:0 0 12px; color:#{accent};\">Accent focus</p>"
      file.puts "      <p style=\"margin:0 0 6px; color:#{diff_added};\">+ added line</p>"
      file.puts "      <p style=\"margin:0 0 12px; color:#{diff_removed};\">- removed line</p>"
      file.puts "      <span style=\"display:inline-block; padding:6px 10px; border-radius:999px; background:#{accent}; color:#{surface}; font-size:11px;\">Continue</span>"
      file.puts "    </div>"
      file.puts "  </section>"
    end
    file.puts '</div>'
  end
end
