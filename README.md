# Impulse42

**Impulse42** ist ein physikbasiertes 2D-Top-Down-Tower-Defense-Spiel (*Sumo Ring-Out*), entwickelt mit der **Godot Engine 4.7** im Rahmen der Projektarbeit *Game & XR Design*.

Anstelle klassischer Lebenspunkte (HP-Leisten) basiert das gesamte Spiel auf Newtonscher Impulsphysik: Gegner versuchen, den schweren, frei beweglichen Energiekern (*Kernel*) über die ungesicherten Kanten einer schwebenden Plattform ins Nichts (*Void*) zu schieben, während der Spieler kinetische Verteidigungsanlagen platziert, um Angreifer von der Plattform zu katapultieren.

---

## Voraussetzungen & Startanleitung (Schritt für Schritt)

1. **Godot Engine 4.7 installieren:**  
   Lade **Godot Engine 4.7** (Standard-Version, getestet mit `4.7.2.stable`) von [godotengine.org](https://godotengine.org/) herunter.
2. **Projekt importieren:**
   * Öffne den Godot Project Manager.
   * Klicke auf **Import** (bzw. *Importieren*) und wähle die Datei `project.godot` im Hauptverzeichnis dieses Repositories aus.
   * Klicke auf **Import & Edit**.
3. **Spiel starten:**
   * Drücke im Godot-Editor **`F5`** (oder klicke oben rechts auf den **Play**-Button ▶), um die Hauptszene (`res://scenes/game.tscn`) zu starten.

---

## Steuerung

| Eingabe | Aktion |
| :--- | :--- |
| **`1` / `2`** (oder HUD-Buttons) | Turmtyp auswählen (`[1] Piston`, `[2] Bumper`) |
| **`R`** | Bau-Vorschau im 90°-Raster drehen |
| **Linksklick** | Ausgewählten Turm auf freier Kachel platzieren |
| **Rechtsklick** | Bau-Vorschau ein-/ausblenden |
| **`Leertaste`** (oder *Start Wave*) | Nächste Gegnerwelle starten |

---

## Spielregeln & Einheiten

* **Niederlage:** Fällt der **Kernel** (`65 kg`) über die Kante der Plattform ins Void, ist die Runde verloren.
* **Wellen-Ziel (Survival & Ring-Out):** Jede der **5 Wellen** hat ein Zeitlimit (`18–26 s`). Eine Welle ist geschafft, sobald entweder **alle Gegner ins Void gestoßen** wurden (Bonus-Credits pro Gegner!) oder der **Countdown abläuft**, während der Kernel noch auf der Plattform ist.
* **Crush- & Impuls-Mechanik am Kernel:** Berührt der Kernel die Basis eines Turms, zermalmt er diesen sofort. Trifft ein **Piston** mit seiner Stoßseite auf den Kernel, versetzt er auch dem Kernel einen Impuls (Rettungsstoß Richtung Mitte – oder Eigenbeschuss Richtung Kante!).
* **Verteidiger:**
  * **Piston (50 Credits):** Aktiver linearer Impuls-Stoß (`1400 Ns`) in Ausrichtungsrichtung – wirkt auf Gegner und den Kernel.
  * **Bumper (25 Credits):** Omnidirektionaler Pinball-Prellpilz (`900 Ns`), der berührende Gegner radial in alle Richtungen wegschleudert und seitlich in Piston-Bahnen ablenkt.
* **Gegner:**
  * **Pusher (`2.5 kg`, 25 Credits):** Schneller Schieber, der kontinuierlich Kraft Richtung Kernel aufbaut.
  * **Juggernaut (`7 kg`, 60 Credits):** Schwerer Rammbock mit hoher Masse und Trägheit; erfordert gezielte Kanten-Treffer oder Ablenkung.

---

## Projektstruktur

```text
impulse-42/
├── assets/          # 32x32 / 32x64 Pixel-Art-Sprites & Tiles
├── docs/            # Game Design Sheet & Projektdokumentation
├── scenes/          # Modulare Godot-Szenen (.tscn)
├── scripts/         # Entkoppelte GDScript-Komponenten (.gd)
└── project.godot    # Godot 4.7 Projekt-, Input- & Physics-Layer-Konfiguration
```

Weitere Details zu Konzept, Architektur, Learnings und Quellen finden sich in [`docs/PROJEKTDOKUMENTATION.md`](docs/PROJEKTDOKUMENTATION.md).

