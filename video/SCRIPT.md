# AirBack launch video, script v1

TL;DR: 75-second 1080p demo for YouTube and the Play listing's promo-video slot. Captions carry the message (EN on top, ES beneath), a calm synth bed underneath, no voiceover in v1. Real captures from the TCL Google TV and the Mac; the iPhone Control Center shot is the one piece the owner records.

## Beats

| # | Time | Picture | Caption EN | Caption ES |
|---|------|---------|------------|------------|
| 1 | 0:00–0:04 | Black starfield, one line | Your TV's AirPlay receiver shouldn't show you ads. | El receptor AirPlay de tu TV no debería mostrarte anuncios. |
| 2 | 0:04–0:09 | AirBack mark, wordmark | AirBack. AirPlay receiver for Google TV. | AirBack. Receptor AirPlay para Google TV. |
| 3 | 0:09–0:17 | TV capture: Overview screen, idle, "Living Room TV" | It shows up under your TV's own name. Nothing to configure. | Aparece con el nombre de tu TV. Nada que configurar. |
| 4 | 0:17–0:24 | TV capture: YouTube playing, then AirBack comes forward on connect | You're watching something. Someone connects. AirBack comes forward. | Estás viendo algo. Alguien se conecta. AirBack pasa al frente. |
| 5 | 0:24–0:32 | iPhone step card (v1) / owner's iPhone recording (v2) | Control Center → Screen Mirroring → tap your TV. | Centro de control → Duplicar pantalla → toca tu TV. |
| 6 | 0:32–0:46 | Split: Mac screen left, TV capture right. Photos, Safari (fajardorentals.com), Keynote | Mirror your Mac, iPhone or iPad. Photos, web, slides, your own videos. | Duplica tu Mac, iPhone o iPad. Fotos, web, presentaciones, tus videos. |
| 7 | 0:46–0:54 | TV capture: mirror stops, TV snaps back to YouTube | Stop mirroring. The TV goes back to what it was showing. | Deja de duplicar. La TV vuelve a lo que estaba mostrando. |
| 8 | 0:54–1:02 | TV capture: Settings screen, Spanish strings visible | Rename it. Keep "return on disconnect" on. English and Spanish. | Cámbiale el nombre. "Volver al desconectar" activado. Inglés y español. |
| 9 | 1:02–1:09 | Card | No ads. No subscription. $3.99 once. Open source, GPL-3.0. | Sin anuncios. Sin suscripción. $3.99 una vez. Código abierto, GPL-3.0. |
| 10 | 1:09–1:15 | End card: mark, "AirBack on Google Play", github.com/FireIslandMan/airback. Small print: DRM line | Netflix, Apple TV+ and Disney+ block every third-party AirPlay receiver. Everything else works. | Netflix, Apple TV+ y Disney+ bloquean todo receptor AirPlay de terceros. Lo demás funciona. |

## Captures

- TV side: `adb screenrecord` on the TCL (1920x1080, 30 fps, 3-minute cap per file). One take covers beats 3, 4, 6 right, 7. A second short take covers beat 8.
- Mac side: `screencapture -v` on the built-in display while mirroring to Living Room TV, cropped to the window region for beat 6 left.
- Owner records for v2: iPhone screen recording of Control Center → Screen Mirroring → Living Room TV (beat 5), and a 10-second phone-camera clip of the TV returning to the DirecTV input (an alternate for beat 7, since the TV's screen capture can't see HDMI inputs).

## Audio

Apple Loops (GarageBand library, royalty-free under Apple's license): the "Afloat" family (Pad, Synth Arp, Beat), looped to length, beat enters at beat 4, everything fades under the end card.

## Deliverables

- `video/build/AirBack-launch-v1.mp4` (1920x1080, H.264, AAC)
- `video/build/thumbnail.jpg` (1280x720)
- `video/YOUTUBE.md` (title, description, tags, chapters, EN and ES)
