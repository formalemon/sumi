# sumi

Dotfiles for `ren@kiri`: Niri on Arch, dressed in Rosé Pine Moon, with the
enso desktop (bar, launcher, control center,
notifications, wallpaper, power menu, lock).

Each directory here is one directory of `~/.config`, linked into place.

```
niri/                 the compositor
  config.kdl            entry point: only a list of includes
  outputs.kdl           monitors
  input.kdl             keyboard, touchpad, mouse
  layout.kdl            gaps, column widths, ring and shadow geometry
  theme.kdl             every colour, and nothing else
  rules.kdl             window and layer rules
  session.kdl           cursor, screenshots, overlays
  autostart.kdl         what starts with niri
  binds.kdl             keys
enso/                 the enso suite
  config.toml           settings (the wallpaper, for now)
  wallpapers/           pictures enso-wall shows
```

## Install

```sh
git clone <this repo> ~/dev/sumi
ln -s ~/dev/sumi/niri ~/.config/niri
ln -s ~/dev/sumi/enso ~/.config/enso
```

The niri config calls the enso tools by name, so they must be on `PATH`
(`~/.local/bin` is). From a checkout of enso:

```sh
cargo build --release
for tool in bar ctl launch notify wall power lock; do
    ln -s "$PWD/target/release/enso-$tool" ~/.local/bin/
done
```

## Keys worth knowing

| Key | Does |
| --- | --- |
| `Mod+Space` | launcher (`enso-launch`) |
| `Mod+C` | control center (`enso-ctl`) |
| `Mod+Shift+E` | power menu (`enso-power`): lock, log out, restart, shut down |
| `Super+Alt+L` | lock (`enso-lock`) |
| `Mod+T` / `Mod+B` | terminal / browser |
| `Mod+Shift+/` | every binding |

## Changing the look

- **Wallpaper:** drop a picture in `enso/wallpapers/` and name it in
  `enso/config.toml`, per theme if you like. `enso-wall list` shows which
  theme gets which.
- **Colours:** `niri/theme.kdl` is the only niri file that names a colour.
  enso follows `enso-ctl theme set <id>` by itself; niri does not yet, so
  copy the new palette's values there (`enso-ctl theme show <id>`).
