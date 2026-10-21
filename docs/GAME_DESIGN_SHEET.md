# Impulse42 – Game Design Sheet

> **Projekt:** Creative Game & XR Experience  
> **Titel:** Impulse42  
> **Engine & Setup:** Godot Engine 4.x (Top-Down 2D Physics)  
> **Visuals & Art Style:** 32×32 Pixel-Art (LibreSprite / DB32 Palette)  

---

## 1. High-Concept Pitch & Zielgruppe

* **Pitch:** In *Impulse42* verteidigst du deinen frei beweglichen Energiekern nicht durch traditionelles HP-Attrition, sondern nutzt Newtons Gesetze ($p = m \cdot v$), um anrückende Gegner über ungeschützte Plattform-Kanten ins Nichts zu katapultieren – während die Gegner versuchen, den tonnenschweren Kern selbst ins Void zu schieben.
* **Zielgruppe:** Fans von physikbasierten Puzzlern und taktischen Strategiespielen, die Freude an emergentem Gameplay, Kettenreaktionen und präziser Physik haben.
* **Design-Philosophie (Pure Physics, No HP Bars):**
  * Weder Einheiten noch der Kern besitzen klassische Trefferpunkte.
  * Primäre Attribute jedes Körpers sind Masse ($m$), Trägheit, lineare Dämpfung und Geschwindigkeit ($v$).
  * **Fail-Condition:** Rein räumlich. Fällt der Kern über die Kante ins Void, ist die Runde verloren (*Sumo Ring-Out*).

---

## 2. Core Gameplay Loop

1. **Scouting & Antizipation:** Analyse anrückender Gegnerwellen (Massenverteilung: leichte Schwärme vs. schwere Schieber).
2. **Kinetische Platzierung:** Kinetische Verteidiger (Pistons, Shockwaves, Bumper) werden auf dem Tile-Grid platziert und im 90°-Raster ausgerichtet.
3. **Schub & Impuls-Auflösung:** Gegner üben permanenten Schub auf den Kern aus; Türme triggern gerichtete Kraftimpulse (`apply_central_impulse`), brechen Pulks und leiten Kräfte um.
4. **Kantensturz & Ökonomie:** Einheiten, die über die ungeschützten Plattformgrenzen fallen, scheiden aus und generieren Kinetik-Credits (inkl. Multiplikatoren bei Kettenstürzen).
5. **Dynamische Arena-Verschiebung:** Der Kern bleibt nach Kollisionen dauerhaft verschoben (hohe Trägheit). Gefährdete Kanten müssen vom Spieler situativ neu abgesichert werden.

---

## 3. Spielfeld & Topologie (Center Core)

* **Arena:** Ein schwebendes Plateau im Vakuum/Void, realisiert über ein Kachel-Raster (`TileMapLayer`).
* **Ungesicherte Kanten:** Die gesamte Begrenzung der Plattform ist ungesichert (freier Fall ins Void per Trigger-Zone / `body_exited`).
* **Crush-Mechanik / Bauverbotszone:**
  * Um den Kern existiert ein dynamischer Ausschlussradius, damit kein Wall-Exploit (vollständiges Einkäfigen) möglich ist.
  * Schwere Kern-Massen zermalmen bei Kollision schwächere Turmstrukturen.

---

## 4. Turm-Arsenal (Kinetische Abwehr)

| Turm | Typ / Mechanik | Taktische Rolle |
| :--- | :--- | :--- |
| **Vector Piston** | Gerichteter linearer Kraftstoß (drehbar via Taste `R`) | Kanten-Finisher; schlägt Gegner im 90°-Winkel von der Schiebebahn ins Void. |
| **Radial Shockwave** | Omnidirektionale Druckwelle ($1/d^2$) | Notfall-Befreiung; zersprengt verkeilte Gegnerpulks direkt am Kern. |
| **Kinetic Bumper** | Passiver Körper mit hoher Restitution ($e > 1.0$) | Günstiges Umlenken; verwandelt frontale Rammbahnen in Querschläger. |
| **Grav-Vortex** | Zentripetales Kraftfeld | Bündelt Gegner für Piston-Schläge oder dient als Bremsanker für den Kern. |

---

## 5. Gegner-Klassen (Masse-Profile)

* **Dart ($m = 0.5$):** Sehr schnell, greift im Schwarm an, fliegt bereits bei minimalen Stößen weit ins Void.
* **Cruiser / Pusher ($m = 2.5 - 4.0$):** Ausgewogenes Profil; legt sich an den Kern an und übt kontinuierliche Schiebekraft in Richtung der nächsten Kante aus.
* **Juggernaut ($m = 10.0$):** Enorme Masse und Trägheit; immun gegen leichte Einzelstöße. Dient als Rammbock oder Querschläger-Gefahr für die eigene Basis.

---

## 6. Ökonomie & Upgrades

* **Kinetische Ernte:** Kantenstürze schütten Credits je nach Gegnergewicht aus. Wuchtige Treffer und Kettenreaktionen ("Strike!") vergeben Combo-Boni.
* **Upgrade-Pfade (T1 $\rightarrow$ T3):**
  * *Piston:* Erhöhte Kraft $\rightarrow$ doppelte Stoßbreite (Wide Hammer).
  * *Shockwave:* Reibungs-Nullung (Glatteis) $\rightarrow$ Implosion/Explosion.
  * *Bumper:* Höhere Bounciness $\rightarrow$ strukturelle Verstärkung gegen Kern-Treffer.
  * *Vortex:* Orbitaler Wirbel $\rightarrow$ Polaritäts-Umschaltung (Abstoßung).

---

## 7. Steuerung & Interface

| Eingabe | Aktion |
| :--- | :--- |
| **Linksklick** | Turm auswählen / auf freier Grid-Kachel bauen |
| **Rechtsklick** | Bau-Vorschau abbrechen / Turm verkaufen |
| **Taste R** | Ghost-Vorschau um 90° drehen |
| **Tasten 1–4** | Schnellauswahl der kinetischen Turmtypen |
| **Leertaste** | Pause / Taktische Planung |

---

## 8. Audiovisueller Stil (Retro Sci-Fi / Steampunk)

* **Pixel-Art:** 32×32 Kacheln erstellt in LibreSprite unter Verwendung der *DawnBringer 32 (DB32)*-Palette.
* **Klare Kanten-Lesbarkeit:** Messing- und Stahlbeschläge an den Außenkanten heben die Absturzzonen deutlich vom dunklen Void ab.
* **Feedback:** Tween-Animationen bei Stößen, Partikel- und Skalierungs-Effekte beim Sturz ins Void.