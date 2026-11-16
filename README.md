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
  theme.kdl             fallback colours; enso-ctl supplies the live ones
  rules.kdl             window and layer rules
  session.kdl           cursor, screenshots, overlays
  autostart.kdl         what starts with niri
  binds.kdl             keys
bash/                 the shell
  profile               login shells: PATH, editor      (~/.bash_profile)
  rc                    interactive shells: history, completion (~/.bashrc)
  prompt                directory, git branch, a mark that reddens on failure
  aliases               shorthands
alacritty/            the terminal: padding, translucency; colours from enso
nvim/                 Neovim: line numbers, rose-pine/neovim, no background of its own
firefox/              Firefox's interface, linked into each profile
  userChrome.css        imports enso's colours; rules of your own below
  user.js               the preference that lets it be styled
enso/                 the enso suite
  config.toml           settings (the wallpaper, for now)
  wallpapers/           pictures enso-wall shows
```

## Install

```sh
git clone https://github.com/formalemon/sumi ~/dev/sumi
~/dev/sumi/install           # link everything into place
~/dev/sumi/install --enso    # …and build enso from ~/dev/enso onto PATH
```

`install` links each directory into `~/.config` (and the two bash files into
`~`, the only names bash reads), makes the directories the configs expect
(`~/Pictures/Screenshots`), and has GTK and Firefox import the colours enso
writes. It can be run again at any time; it never overwrites a file that is
not its own.

## Keys worth knowing

| Key | Does |
| --- | --- |
| `Mod+Space` | launcher (`enso-launch`) |
| `Mod+C` | control center (`enso-ctl`) |
| `Mod+Shift+E` | power menu (`enso-power`): lock, log out, restart, shut down |
| `Super+Alt+L` | lock (`enso-lock`) — also by itself after 5 minutes alone, and before sleep |
| `Mod+T` / `Mod+B` | terminal / browser |
| `Mod+Shift+/` | every binding |

## Changing the look

- **Wallpaper:** drop a picture in `enso/wallpapers/` and name it in
  `enso/config.toml`, per theme if you like. `enso-wall list` shows which
  theme gets which.
- **Colours:** `enso-ctl theme set <id>` recolours enso, niri, Alacritty,
  Neovim, GTK dialogs, and Firefox together.
  niri picks the palette up from `~/.local/state/enso/niri.kdl`, which
  enso-ctl writes; `niri/theme.kdl` is the fallback until it exists.
