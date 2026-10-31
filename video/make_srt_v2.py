#!/usr/bin/env python3
"""EN/ES captions and chapter list for AirBack-launch-v2, matching assemble-v2.sh (crossfaded joins)."""
import os, sys
B = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build")
XF = 0.6
have_phone = os.path.exists(os.path.join(B, "..", "src", "veo-phone.mp4"))
have_tv = os.path.exists(os.path.join(B, "..", "src", "veo-tv.mp4"))
segs = [
    ("01", 5.0, "Your TV's AirPlay receiver shouldn't show you ads.", "El receptor AirPlay de tu TV no debería mostrarte anuncios.", "The problem"),
    ("02", 5.5, "AirBack. AirPlay receiver for Google TV.", "AirBack. Receptor AirPlay para Google TV.", None),
    ("03", 8.0, "It shows up under your TV's own name. Nothing to configure.", "Aparece con el nombre de tu TV. Nada que configurar.", "Your TV's own name"),
    ("04", 7.5, "You're watching something. Someone connects. AirBack comes forward.", "Estás viendo algo. Alguien se conecta. AirBack pasa al frente.", "Comes forward on connect"),
    ("05", 8.5 if have_phone else 7.5, "Control Center, Screen Mirroring, tap your TV.", "Centro de control, Duplicar pantalla, toca tu TV.", "Connecting from an iPhone"),
    ("06a", 7.0, "Mirror your Mac, iPhone or iPad. Photos, web, slides, your own videos.", "Duplica tu Mac, iPhone o iPad. Fotos, web, presentaciones, tus videos.", "Mirroring a Mac"),
    ("06b", 7.0, "Your own videos, full screen, no cable.", "Tus propios videos, a pantalla completa, sin cable.", None),
    ("07", 7.5, "Stop mirroring. The TV goes back to what it was showing.", "Deja de duplicar. La TV vuelve a lo que estaba mostrando.", "Stop, and the TV goes back"),
]
if have_tv:
    segs.append(("07b", 7.5, "Same thing with live TV: it goes back to the input you were on.", "Igual con TV en vivo: vuelve a la entrada en la que estabas.", None))
segs += [
    ("08", 8.0, "Rename it. Keep \"return on disconnect\" on. English and Spanish.", "Cámbiale el nombre. \"Volver al desconectar\" activado. Inglés y español.", "Settings"),
    ("09", 7.0, "No ads. No subscription. $3.99 once. Open source, GPL-3.0.", "Sin anuncios. Sin suscripción. $3.99 una vez. Código abierto, GPL-3.0.", "Price and license"),
    ("10", 8.0, "Netflix, Apple TV+ and Disney+ block every third-party AirPlay receiver. Everything else works.", "Netflix, Apple TV+ y Disney+ bloquean todo receptor AirPlay de terceros. Lo demás funciona.", None),
]
def ts(t):
    h = int(t // 3600); m = int(t % 3600 // 60); s = t % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}".replace(".", ",")
def mmss(t): return f"{int(t//60)}:{int(t%60):02d}"
starts = []; t = 0.0
for i, (n, d, *_ ) in enumerate(segs):
    starts.append(t); t += d - (XF if i < len(segs) - 1 else 0)
total = t
for lang, idx in (("en", 2), ("es", 3)):
    out = []; k = 1
    for (n, d, en, es, ch), st in zip(segs, starts):
        text = (en, es)[idx - 2]
        if not text: continue
        a = st + 0.7; b = st + d - 1.2
        out.append(f"{k}\n{ts(a)} --> {ts(b)}\n{text}\n"); k += 1
    open(os.path.join(B, f"AirBack-launch-v2-{lang}.srt"), "w").write("\n".join(out))
print("total", round(total, 2), "s")
print("chapters:")
for (n, d, en, es, ch), st in zip(segs, starts):
    if ch: print(mmss(st if st > 0 else 0), ch)
