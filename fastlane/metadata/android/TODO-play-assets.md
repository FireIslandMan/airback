# Play Store assets still to capture by hand

Upstream's phone screenshots and feature graphic were removed; they showed the
old app and do not represent AirBack. Nothing here can be generated from the
repo, so it stays a manual step.

## TV screenshots (required for a TV listing): at least two, 1920x1080 PNG

Save them as `en-US/images/tvScreenshots/1.png`, `2.png`, ... (fastlane
supply uploads that folder as the Android TV screenshots). Capture on the TCL
over adb (`adb shell screencap -p`, then strip the shell's text prefix up to
the PNG signature) or with the TV's own screenshot feature.

1. Mirroring in progress: an iPhone home screen or Photos app mirrored full
   screen on the TV, so the listing shows the core job.
2. The "TV goes back" moment: the live TV channel or HDMI input that AirBack
   restored after the iPhone disconnected. Pair it with screenshot 1 so the
   before/after reads at a glance.
3. (Optional) The AirBack idle screen showing the receiver name ("Living Room
   TV") so buyers see where to look on their iPhone.
4. (Optional) The settings screen with the PIN and resolution options.

Avoid any screenshot that shows a Netflix, Apple TV+ or Disney+ frame.

## Feature graphic: 1024x500 PNG at `en-US/images/featureGraphic.png`

Amber #F59E0B on near-black #05070D with the starfield, the two-screens icon
from `design/airback-play-icon-512.png`, and the line "Gives you your TV back".
No text smaller than ~40 px; Play crops the edges on some surfaces.

## Also missing from the repo

- A public source URL for the AirBack fork. GPL-3.0 requires offering the
  source to buyers; add it to the last paragraph of `full_description.txt` in
  all three locales once the repo is public.

Update 2026-10-18 20:40: feature graphic (1024x500) and two TV screenshots (overview, settings) are now in
en-US/images. Still wanted: one hero screenshot of a real mirroring session from an iPhone (Photos on a landscape
photo or Apple Maps, nothing personal), captured with `adb exec-out screencap -p` while the session is live.
Form answers are in PLAY-CONSOLE-ANSWERS.md.
