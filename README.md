# sumi

Dotfiles for `ren@kiri`: Niri on Arch, dressed in Rosé Pine Moon — and,
if you want it, the [enso](https://github.com/formalemon/enso) desktop (bar,
launcher, control center, notifications, wallpaper, power menu, lock, file
manager, image viewer, password prompt, keyring, what's playing, clipboard
history, night light, login screen). The dotfiles stand on their own: each enso tool
adds its part only when it's picked at install.

Each directory here is one directory of `~/.config`, linked into place.

```
niri/                 the compositor
  config.kdl            entry point: only a list of includes (the few enso
                        parts that must come first, then core/, then enso/)
  core/                 niri on its own, needing nothing else
    outputs.kdl           monitors
    input.kdl             keyboard, touchpad, mouse
    layout.kdl            gaps, column widths, ring and shadow geometry
    theme.kdl             colours, from theme/ (enso-ctl, if picked, writes
                          the live ones)
    rules.kdl             window and layer rules
    session.kdl           cursor behaviour, screenshots, overlays
    binds.kdl             keys (volume through wpctl, media keys through
                          busctl to the first MPRIS player)
  enso/                 what each enso tool adds: what it starts, its keys,
                        its rules — bar, launch, ctl, notify, wall, power,
                        lock, files, auth, play (Mod+P and the media
                        keys), clip (Mod+Ctrl+V), dusk; included only for
                        the tools picked (keyring and view have none)
    first/                what a tool must say before core/: the screens
                          the control center keeps (niri reads the first
                          section it finds for a screen)
bash/                 the shell, pure bash: nothing to install
  profile               login shells: PATH, editor, INPUTRC (~/.bash_profile)
  rc                    interactive shells: history, colours (~/.bashrc)
  inputrc               editing: Tab cycles completions, Ctrl+arrows by word
  prompt                path, git state, time taken, exit status — see below
  aliases               shorthands
fontconfig/           sans-serif and monospace: the fonts enso is set to
                      (enso writes them), then Adwaita for what they lack,
                      then Noto Color Emoji
alacritty/            the terminal: padding, translucency, a blinking bar
                      cursor; colours from theme/, then enso's over them
nvim/                 Neovim, one module per concern; plugins through vim.pack,
                      pinned in nvim-pack-lock.json
  lua/sumi/             options, keys, autocmds, the theme (rose-pine, from
                        enso), a statusline of its own, tree-sitter
                        (nvim-treesitter), the working directory following
                        the project, mini.pick, mini.diff, nvim-tree, LSP
                        with built-in completion, key hints when you pause
                        (mini.clue), and a start screen: an ensō and your
                        recent projects
  lsp/                  a file per language server; each starts only when
                        its program is installed
firefox/              Firefox's interface, linked into each profile
  userChrome.css        imports the colours (theme/'s, then enso's from
                        enso.css, which install links to where enso writes
                        them); rules of your own below
  user.js               the preference that lets it be styled
theme/                the colours, without enso
  rose-pine-moon.toml   the palette, in enso's own theme format
  templates/            alacritty, Firefox, and niri, colours by role
  render                writes their colour files from the palette (install
                        runs it; --check only looks)
enso/                 enso's settings (linked only if a tool is picked)
  config.toml           the fonts, the cursor, the wallpaper
  wallpapers/           pictures enso-wall shows
system/               how the machine starts, for root to set up by hand:
                      the boot menu, a small initramfs, a quiet boot, the
                      splash, the login screen (install never runs these);
                      ./system/check says what's still to do
```

## Install

```sh
git clone https://github.com/formalemon/sumi ~/dev/sumi
~/dev/sumi/install                     # link everything, then ask about enso
~/dev/sumi/install --enso              # …all the enso tools, without asking
~/dev/sumi/install --enso=bar,files    # …just these
~/dev/sumi/install --no-enso           # …none: the dotfiles alone
~/dev/sumi/install --enso-dev          # enso built from ~/dev/enso, for working on it
```

`install` links each directory into `~/.config` (and the two bash files into
`~`, the only names bash reads), makes the directories the configs expect
(`~/Pictures/Screenshots`), and fetches the cursor and the fonts. Then it
asks about enso: **Y**es, all of it (the default), **n**o, or **s**ome — one
question per tool, your last answers the defaults. For the tools picked it
puts enso's release on `PATH` — the version pinned in `install`, fetched
into `~/.local/share/enso/release` and checked, as the fonts are — links
`enso/`, writes
`~/.local/state/sumi/niri-enso.kdl` (the list of `niri/enso/` parts niri
includes), has GTK import the control center's colours, and lets enso-files
set itself up as every app's file chooser and what folders open in
(`enso-files portal enable`), enso-view as what pictures open in
(`enso-view enable`), and enso-keyring as the session's keyring
(`enso-keyring enable`). With
enso-greet it runs `enso-greet enable`, which readies the login screen and
prints the few lines root has to run; sumi runs nothing as root. Tools
dropped on a later run are taken away again. It can be run again at any
time; it never overwrites a file that is not its own.

Working on enso itself, `--enso-dev` builds the picked tools from
`~/dev/enso` (or `$ENSO`) and puts those on `PATH` instead, ahead of the
release; the choice is remembered, and `--enso-release` goes back. A new
enso release reaches a machine when the pin in `install` (two lines) moves
to it and `install` runs again.

The cursor and the fonts come from their authors' own GitHub releases, not
packages: [Bibata Modern Ice](https://github.com/ful1e5/Bibata_Cursor/releases)
into `~/.local/share/icons`, and Google Sans —
[Flex](https://github.com/googlefonts/googlesans-flex/releases) for the
interface, [Code](https://github.com/googlefonts/googlesans-code/releases)
for the terminal, both under the SIL Open Font License — into
`~/.local/share/fonts`, with [Noto Color
Emoji](https://github.com/googlefonts/noto-emoji) (the font file of a tagged
release, same licence) behind them for emoji. `install` downloads the pinned versions, checks each
against the SHA-256 written in the script, and unpacks it with `bsdtar`
(pacman's own libarchive). enso then tells every program to use them
(`font`, `mono_font`, and `cursor` in `enso/config.toml`).

## Keys worth knowing

With the enso tools (each key comes with its tool):

| Key | Does |
| --- | --- |
| `Mod+Space` | launcher (`enso-launch`) |
| `Mod+C` | control center (`enso-ctl`) |
| `Mod+Shift+E` | power menu (`enso-power`): lock, sleep, log out, restart, shut down |
| `Mod+Ctrl+V` | clipboard history (`enso-clip`): Enter copies the one chosen |
| `Super+Alt+L` | lock (`enso-lock`) — also by itself after 5 minutes alone, and before sleep |
| `Mod+E` | files (`enso-files`) |
| `Mod+T` / `Mod+B` | terminal / browser |
| `Print` / `Mod+Shift+S` | screenshot: drag a box, Space for the whole screen |
| Display key | the control center's Displays page (kept for next time) |
| Calculator key | the launcher, ready for a sum |
| Keyboard light keys | the keyboard's light, its level on the bar |
| `Mod+Shift+/` | every binding |

## Changing the look

- **Wallpaper:** drop a picture in `enso/wallpapers/` and name it in
  `enso/config.toml`, per theme if you like. `enso-wall list` shows which
  theme gets which.
- **Colours:** `enso-ctl theme set <id>` recolours enso, niri, Alacritty,
  Neovim, GTK dialogs, Firefox, and the shell prompt together. Without
  enso they are `theme/rose-pine-moon.toml`'s: change it and run
  `theme/render` (or install). If it no longer matches enso's own
  rose-pine-moon, install adds it to enso as the theme `sumi` and picks it.
- **Cursor:** `cursor` and `cursor_size` in `enso/config.toml`, or
  `enso-ctl cursor set <name> [size]` to try one; `enso-ctl cursor` lists
  what is installed. niri, GTK, and everything else follow at once.
  niri picks the palette up from `~/.local/state/enso/niri.kdl`, which
  enso-ctl writes; `niri/theme.kdl` is the fallback until it exists.

## The prompt

```
~/dev/enso   main ⇡1 +2 !1 ?3   12s
❯
```

The path (the last three directories of a deep one), then — in a git
repository — the branch, commits ahead ⇡ and behind ⇣, staged +, changed !,
untracked ?, stashed ≡, conflicts ✖, and a rebase or merge under way. After
a command that took over two seconds, how long; after one that failed, ✘
and its status or signal, and the ❯ turns red. Over SSH it starts with
user@host; in a Python virtualenv, or with jobs in the background, it says
so.

Every colour is one of the terminal's sixteen, so it follows
`enso-ctl theme set`. It is pure bash: outside a repository it runs nothing,
inside one a single `git status` (a few milliseconds).
