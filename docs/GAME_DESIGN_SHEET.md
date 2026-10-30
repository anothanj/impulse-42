# Impulse42 – Game Design Sheet

> **Projekt:** Game & XR Design  
> **Titel:** Impulse42  
> **Engine & Setup:** Godot Engine 4.7 (Top-Down 2D Physics, keine Gravitation)  
> **Visuals & Art Style:** 32×32 Pixel-Art (LibreSprite / DB32 Palette)  

---

## 1. High-Concept Pitch & Zielgruppe

* **Pitch:** In *Impulse42* verteidigst du deinen frei beweglichen Energiekern nicht durch traditionelles HP-Attrition, sondern nutzt Newtons Gesetze ($p = m \cdot v$), um anrückende Gegner über ungeschützte Plattform-Kanten ins Nichts zu katapultieren – während die Gegner versuchen, den schweren Kern selbst ins Void zu schieben.
* **Zielgruppe:** Fans von physikbasierten Puzzlern und kompakten Taktikspielen, die Freude an emergentem Gameplay, Abprallwinkeln und präziser Impulsphysik haben.
* **Design-Philosophie (Pure Physics, No HP Bars):**
  * Weder Einheiten noch der Kern besitzen klassische Trefferpunkte.
  * Primäre Attribute jedes Körpers sind Masse ($m$), lineare Dämpfung, Elastizität (`bounce`) und Kraftstoß (`impulse`).
  * **Fail-Condition:** Rein räumlich. Fällt der Kern über die Kante ins Void, ist die Runde verloren (*Sumo Ring-Out*).

---

## 2. Core Gameplay Loop

1. **Aufbauphase & Positionierung:** Analyse der offenen Plattformkanten; Platzierung kinetischer Verteidiger (**Piston**, **Bumper**) auf dem `32×32` Tile-Grid inkl. 90°-Rotation.
2. **Wellenstart & Schub-Physik:** Gegnerwellen (**Pusher** und schwere **Juggernauts**) spawnen an fokussierten Flanken der Plattform und üben kontinuierlichen Schub auf den **Kernel** aus.
3. **Impuls & Ablenkung:** Passive **Bumper** reflektieren Angreifer elastisch aus ihrer Bahn, während aktive **Pistons** Gegner per gerichtetem Kraftstoß über die Kante befördern.
4. **Kantensturz, Zeitlimit & Ökonomie:** Über die Kante gestoßene Gegner scheiden im Void aus und schütten sofort Credits aus. Jede Welle besitzt zudem ein Überlebens-Zeitlimit (`18–26 s`), um Pattsituationen zu verhindern: Läuft die Zeit ab, deaktivieren sich verbliebene Gegner (ohne Kill-Prämie) und der Wellen-Bonus (`+50` Credits) wird vergeben.
5. **Dynamische Verschiebung & Crush-Gefahr:** Wird der verschobene Kernel (`65 kg`) gegen Turm-Basen gedrückt, zermalmt er diese sofort; gerät er in die Schlagzone eines **Pistons**, erhält auch der Kernel den vollen Kraftstoß.

---

## 3. Spielfeld & Topologie

* **Arena:** Ein schwebendes `28×15` Kachel-Plateau im Void, umgesetzt über `TileMapLayer`.
* **Ungesicherte Kanten:** Die gesamte Außenkante der Plattform ist offen; das Verlassen der `Boundaries`-Zone (`Area2D`) führt unmittelbar zum Ring-Out.
* **Anti-Caging & Crush-Mechanik:**
  * Direkt um den Kernel verhindert ein Ausschlussradius (`72 px`) das unmittelbare Zubauen.
  * Kollidiert der rollende Kernel mit einem platzierten Turm (`StaticBody2D`), wird dieser zermalmt (`queue_free()`) und die Kachel wieder freigegeben. Ein permanentes Einkäfigen des Kerns ist damit ausgeschlossen.

---

## 4. Einheiten & Physik-Profile

### Kinetische Verteidiger (Türme)

| Turm | Kosten | Mechanik | Taktische Rolle |
| :--- | :---: | :--- | :--- |
| **Vector Piston** | 50 | Gerichteter Kraftstoß (`1400` Ns, drehbar per `R`) auf Gegner & Kernel | Aktiver Kanten-Finisher (oder Notfall-Schubser für den Kernel); schlägt Gegner weit Richtung Abgrund. |
| **Kinetic Bumper** | 25 | Omnidirektionaler Pinball-Prellpilz (`900` Ns radialer Rückstoß + `bounce = 1.0`) | Günstiger Wellenbrecher & Umlenker; schleudert Gegner nach dem Flipper-Prinzip schräg aus ihrer Rammbahn. |

### Gegner-Klassen (Masse-Profile)

| Gegner | Masse | Schubkraft | Belohnung | Verhalten |
| :--- | :---: | :---: | :---: | :--- |
| **Pusher** | `2.5 kg` | `280 N` | 25 Credits | Schneller, wendiger Standardschieber; fliegt bei einzelnen Piston-Treffern über das halbe Feld ins Void. |
| **Juggernaut** | `7.0 kg` | `750 N` | 60 Credits | Dreifache Masse und hohe Schubkraft; steckt frontale Einzelstöße schwerer weg und erfordert Kanten-Positionierung. |

---

## 5. Steuerung & Interface

| Eingabe | Aktion |
| :--- | :--- |
| **Tasten `1` / `2`** (oder HUD-Buttons) | Auswahl zwischen **Piston** und **Bumper** |
| **Taste `R`** | Ghost-Vorschau im 90°-Raster drehen |
| **Linksklick** | Ausgewählten Turm auf gültiger Kachel bauen |
| **Rechtsklick** | Bau-Vorschau ein-/ausblenden |
| **Leertaste** (oder *Start Wave*) | Nächste Gegnerwelle starten |
