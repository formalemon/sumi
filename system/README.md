# system

Changes outside `$HOME` that make the machine start quietly and look like
the rest of sumi. They need root. `install` never reads or runs anything
here: each step is something to read, then type yourself, and each says
how to undo it.

The machine these were written for: systemd-boot, an Intel + NVIDIA laptop
(`nvidia_drm.modeset=1`), mkinitcpio with the `systemd` hook. Other
machines need the same ideas with their own details.

## 1. Firmware: a shorter maker's logo

The firmware's logo can't be replaced on most laptops without flashing a
modified firmware, which isn't worth the risk. It can be made shorter: in
the firmware setup (F2 at power-on on ASUS), **Boot → Fast Boot → Enabled**.
That skips most of the hardware checks; Esc at power-on still reaches the
boot menu. If a USB stick stops being offered at boot, turn it off again.

## 2. A quiet boot

No scrolling text between the boot menu and the login: the kernel and
systemd say only what is wrong, and the console cursor stays hidden.

Find the boot entry and add to its `options` line:

```sh
sudo ls /boot/loader/entries/          # arch.conf, or similar
sudoedit /boot/loader/entries/arch.conf
```

```
quiet loglevel=3 rd.udev.log_level=3 systemd.show_status=auto vt.global_cursor_default=0
```

so that it reads, in full,

```
options root=UUID=… rw nvidia_drm.modeset=1 nvidia_drm.fbdev=1 quiet loglevel=3 rd.udev.log_level=3 systemd.show_status=auto vt.global_cursor_default=0
```

Errors still show; `journalctl -b` has everything. `vt.global_cursor_default=0`
hides the cursor on every console, a console login's too; leave it out if
that bothers you. To undo: take the words out again.

## 3. The console in Rosé Pine Moon

The console's sixteen colours, from `theme/rose-pine-moon.toml` the way
the terminal maps them, except that black is the base colour, so the
console's background is the desktop's. Add to the same `options` line:

```
vt.default_red=35,235,62,246,156,196,234,224,110,235,62,246,156,196,234,224 vt.default_grn=33,111,143,193,207,167,154,222,106,111,143,193,207,167,154,222 vt.default_blu=54,146,176,119,216,231,151,244,134,146,176,119,216,231,151,244
```

Colour 6 (cyan) is rose here, which the next step uses. If the palette
changes, these are its colours in the order base, love, pine, gold, foam,
iris, rose, text, then muted and the same seven again, as decimal red,
green and blue.

## 4. The ensō at the console login

`/etc/issue` is what a console login (and greetd's plain `agreety`) shows
above the prompt. This puts the ensō there, from the Neovim start screen,
in rose (colour 6, above):

```sh
sudo cp /etc/issue /etc/issue.orig
{
    printf '\e[36m\n'
    cat <<'ART'
                     █▄▄▄
         ▄▄█▀▀       ▀█████
        ██▀            ▀████▄
      ▄█▀                ████▄
      ██                  ████
     ██                   ████
     ██                   ████
     ██▄                  ████
      ███                ████
       ▀██▄            ▄████
        ▀████▄▄▄▄▄▄▄▄█████▀
           ▀███████████▀
                ▀▀▀
ART
    printf '\e[0m\n  \\S  \\l\n\n'
} | sudo tee /etc/issue >/dev/null
```

The last line keeps what a login prompt usually says: the system's name
and the console (`\S` and `\l`, which both the console login and agreety
understand). To undo: `sudo mv /etc/issue.orig /etc/issue`.

## 5. A login screen: greetd

[greetd](https://sr.ht/~kennylevinsen/greetd/) (`pacman -S greetd`)
replaces the console login on the first console. It runs a *greeter*,
which asks who you are and starts your session.

- **With enso**, its login screen is a greeter for greetd:
  `enso-greet enable` writes greetd's configuration and its own, and
  prints the lines to run as root. `install` runs `enable` when `greet`
  is one of the enso tools picked.
- **Without enso**, greetd's own `agreety` asks at the console, with the
  ensō above it (step 4). `/etc/greetd/config.toml`:

  ```toml
  [terminal]
  vt = 1

  [default_session]
  command = "agreety --cmd 'bash -l -c niri-session'"
  user = "greeter"
  ```

Starting greetd takes over the first console and **ends whatever is
logged in there** (the desktop, if it was started from that console).
Save your work and log out first, then log in on another console
(Ctrl+Alt+F2) and try it without making it permanent:

```sh
sudo systemctl start greetd                                   # try it
sudo systemctl stop greetd && sudo systemctl start getty@tty1 # back
sudo systemctl enable greetd                                  # keep it
sudo systemctl disable greetd                                 # undo, from the next start
```

## 6. A boot menu with a picture

- **With enso**, `enso-boot` is a boot menu for the firmware: Arch or
  Windows over voxel rice terraces at dusk, then the ensō while Arch
  starts quietly (steps 2 and 3). `enso-boot install` prints the steps,
  starting with trying it from systemd-boot's own menu. It starts Arch as
  systemd-boot's entry says, so step 2's options apply to both.
- **Without enso**, systemd-boot's menu stays as it is.
