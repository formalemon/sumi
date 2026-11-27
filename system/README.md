# system

Changes outside `$HOME`: how the machine starts, from the power button to
the desktop. They need root, so `install` never reads or runs anything
here. Each step is something to read and then type yourself, and each
says how to undo it.

`./check` compares the machine with this file and lists what's still to
do, with the command for each. It only looks; it changes nothing and
needs no root. Run it after a reinstall, or after a big update.

The machine these were written for: an ASUS laptop with Intel graphics
driving its panel and an NVIDIA card beside it, systemd-boot, and
mkinitcpio with the `systemd` hook. Other machines need the same ideas
with their own details.

What it comes to, in order:

1. The firmware's logo, shorter (Fast Boot).
2. A boot menu with a picture (enso-boot), Arch or Windows.
3. A small initramfs: Intel's driver only.
4. A quiet boot: no text, and the first console kept graphical.
5. A boot splash (Plymouth): the login screen's terraces while Linux starts.
6. A login screen (greetd and enso-greet), straight into niri.
7. Optional: the console in Rosé Pine Moon, and the ensō above a console
   login.

Steps 2, 5 and 6 are enso's. Without enso, skip them; the rest still
stands.

## 1. Firmware: a shorter logo

The firmware's logo can't be replaced on most laptops without flashing a
modified firmware, which isn't worth the risk. It can be made shorter: in
the firmware setup (F2 at power-on on ASUS), **Boot → Fast Boot →
Enabled**. That skips most of the hardware checks. Esc at power-on still
reaches the firmware's boot menu. If a USB stick stops being offered at
boot, turn it off again.

`check` can't see this one.

## 2. A boot menu: enso-boot

enso-boot is a boot menu for the firmware: Arch or Windows under a voxel
pagoda on an island in the sky at dusk, the camera circling it. It never
picks for you. It starts Arch as
systemd-boot's entry says, so the kernel options (step 4) apply to both
menus. systemd-boot stays underneath it.

```sh
cd ~/dev/enso
cargo build --release -p enso-boot --target x86_64-unknown-uefi
cargo run --release -p enso-boot -- install     # prints the steps
```

In short, it copies the menu to `/boot/EFI/enso/enso-boot.efi`, adds a
systemd-boot entry for it, and makes that entry the default, with
systemd-boot's own menu hidden:

```sh
printf 'title enso\nefi /EFI/enso/enso-boot.efi\n' | sudo tee /boot/loader/entries/enso.conf
sudo sed -i -e '/^default/d' -e '/^timeout/d' /boot/loader/loader.conf
printf 'default enso.conf\ntimeout 0\n' | sudo tee -a /boot/loader/loader.conf
```

Holding Space at power-on shows systemd-boot's menu, and Esc in enso's
goes back to it. To undo: put `default` and `timeout` in `loader.conf`
back as they were, and `sudo rm /boot/loader/entries/enso.conf`.

## 3. A small initramfs: Intel only

The laptop's panel is wired to the Intel GPU. The NVIDIA card drives only
the external ports, so its driver doesn't need to be in the initramfs:
it loads a moment later, from the system itself, with the same options.
Without it the initramfs is about 200 MB smaller, which saves about two
seconds of the firmware reading it. It also stops the NVIDIA driver from
arriving in the middle of the boot splash and blanking it.

In `/etc/mkinitcpio.conf`:

```
MODULES=(i915)
HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck)
```

(`plymouth` is for step 5; leave it out without the splash.) Then:

```sh
sudo mkinitcpio -P
```

To undo: `MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)`,
and `sudo mkinitcpio -P` again.

## 4. A quiet boot

No scrolling text between the boot menu and the login. The kernel and
systemd say only what is wrong, and the first console stays graphical
from the splash to the desktop. These go on the `options` line of the
Arch entry in `/boot/loader/entries/` (`sudo ls` it to find the name; not
the fallback):

| Option | Why |
| --- | --- |
| `quiet loglevel=3 rd.udev.log_level=3 systemd.show_status=auto` | Only errors are printed |
| `vt.global_cursor_default=0` | No blinking cursor on any console |
| `splash` | Plymouth shows its splash (step 5) |
| `fbcon=vc:2-63` | Text consoles on 2 and up only. On the first console the kernel never switches to text, which held up the desktop for most of a second at login |

This adds whichever are missing, and leaves the rest of the line alone:

```sh
f=/boot/loader/entries/arch.conf
for w in quiet loglevel=3 rd.udev.log_level=3 systemd.show_status=auto \
         vt.global_cursor_default=0 splash fbcon=vc:2-63; do
  sudo grep -q "^options.* $w\b" "$f" || sudo sed -i "/^options/ s/\$/ $w/" "$f"
done
```

`journalctl -b` still has everything. With `fbcon=vc:2-63`, an emergency
shell on the first console can't be seen. If the machine ever fails to
start, hold Space at power-on, highlight Arch, press `e`, and delete it
for that boot. Ctrl+Alt+F2 always gives a text login. To undo: take the
words out again.

## 5. A boot splash: Plymouth

Plymouth (`pacman -S plymouth`) keeps a picture on the screen while Linux
starts. With enso, the theme is the login screen's: the terraces,
quietened, still, from the boot menu's last frame until the login screen
draws the same picture.

`enso-greet enable` (step 6) writes the theme to
`~/.local/share/enso/greet/plymouth` and prints the lines that put it in
place, in short:

```sh
sudo rm -rf /usr/share/plymouth/themes/enso
sudo cp -r ~/.local/share/enso/greet/plymouth /usr/share/plymouth/themes/enso
sudo install -Dm644 ~/.local/share/enso/greet/plymouth-quit.conf \
    /etc/systemd/system/plymouth-quit.service.d/enso.conf
sudo plymouth-set-default-theme enso
sudo mkinitcpio -P      # the theme lives in the initramfs
```

The drop-in has Plymouth leave its last frame up when it goes, for the
login screen to draw over. Plymouth's first frame switches the panel out
of the firmware's mode, which blanks it for about a second; something has
to, once each boot.

Without enso, `sudo plymouth-set-default-theme bgrt` shows the maker's
logo instead. To undo: take `plymouth` out of HOOKS and `splash` out of
the options, `sudo mkinitcpio -P`, and `sudo pacman -Rns plymouth`.

## 6. A login screen: greetd

[greetd](https://sr.ht/~kennylevinsen/greetd/) (`pacman -S greetd`)
replaces the console login on the first console. It runs a *greeter*,
which asks who you are and starts your session.

- **With enso**, the greeter is enso-greet: the terraces, your name and a
  password field, then niri. `enso-greet enable` (which
  `install` runs when `greet` is one of the enso tools picked) writes its
  files and prints the lines to run as root. Run it again after
  rebuilding enso.
- **Without enso**, greetd's own `agreety` asks at the console, with the
  ensō above it (step 7). `/etc/greetd/config.toml`:

  ```toml
  [terminal]
  vt = 1

  [default_session]
  command = "agreety --cmd 'bash -l -c niri-session'"
  user = "greeter"
  ```

Then make it the login and restart. It has to start with the machine:
started from a running desktop, it can't have the screen, and you get a
dead console.

```sh
sudo systemctl enable greetd && systemctl reboot
```

If the login screen doesn't come up: Ctrl+Alt+F2, log in there, and
`sudo systemctl disable greetd && systemctl reboot` brings the console
login back. `journalctl -b -1 -t enso-greet` says what went wrong.

## 7. Optional: the consoles in Rosé Pine Moon

These show on the text consoles: 2 and up, with step 4.

**Colours.** The consoles' sixteen colours, from `theme/rose-pine-moon.toml`
the way the terminal maps them, except that black is the base colour, so
the console's background is the desktop's. Add to the same `options` line:

```
vt.default_red=35,235,62,246,156,196,234,224,110,235,62,246,156,196,234,224 vt.default_grn=33,111,143,193,207,167,154,222,106,111,143,193,207,167,154,222 vt.default_blu=54,146,176,119,216,231,151,244,134,146,176,119,216,231,151,244
```

Colour 6 (cyan) is rose here, which the next part uses. If the palette
changes, these are its colours in the order base, love, pine, gold, foam,
iris, rose, text, then muted and the same seven again, as decimal red,
green and blue.

**The ensō above a console login.** `/etc/issue` is what a console login
(and greetd's plain `agreety`) shows above the prompt. This puts the ensō
from the Neovim start screen there, in rose (colour 6, above):

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
