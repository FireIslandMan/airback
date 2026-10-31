#!/usr/bin/env python3
"""Writes EN and ES caption files that match assemble.sh's segment timings."""
import os
B = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build")
# (duration, EN, ES) in assemble.sh order; None = no caption
segs = [
    (4.5, "Your TV's AirPlay receiver shouldn't show you ads.", "El receptor AirPlay de tu TV no debería mostrarte anuncios."),
    (5.0, "AirBack. AirPlay receiver for Google TV.", "AirBack. Receptor AirPlay para Google TV."),
    (8.0, "It shows up under your TV's own name. Nothing to configure.", "Aparece con el nombre de tu TV. Nada que configurar."),
    (7.0, "You're watching something. Someone connects. AirBack comes forward.", "Estás viendo algo. Alguien se conecta. AirBack pasa al frente."),
    (7.5, "Control Center, Screen Mirroring, tap your TV.", "Centro de control, Duplicar pantalla, toca tu TV."),
    (14.0, "Mirror your Mac, iPhone or iPad. Photos, web, slides, your own videos.", "Duplica tu Mac, iPhone o iPad. Fotos, web, presentaciones, tus videos."),
    (8.0, "Stop mirroring. The TV goes back to what it was showing.", "Deja de duplicar. La TV vuelve a lo que estaba mostrando."),
    (8.0, "Rename it. Keep \"return on disconnect\" on. English and Spanish.", "Cámbiale el nombre. \"Volver al desconectar\" activado. Inglés y español."),
    (7.0, "No ads. No subscription. $3.99 once. Open source, GPL-3.0.", "Sin anuncios. Sin suscripción. $3.99 una vez. Código abierto, GPL-3.0."),
    (7.0, "Netflix, Apple TV+ and Disney+ block every third-party AirPlay receiver. Everything else works.", "Netflix, Apple TV+ y Disney+ bloquean todo receptor AirPlay de terceros. Lo demás funciona."),
]
def ts(t):
    h = int(t // 3600); m = int(t % 3600 // 60); s = t % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}".replace(".", ",")
for lang, idx in (("en", 1), ("es", 2)):
    t = 0.0; out = []
    for n, seg in enumerate(segs, 1):
        d = seg[0]; text = seg[idx]
        out.append(f"{n}\n{ts(t + 0.5)} --> {ts(t + d - 0.6)}\n{text}\n")
        t += d
    with open(os.path.join(B, f"AirBack-launch-v1-{lang}.srt"), "w") as f:
        f.write("\n".join(out))
print("total", t, "s")
