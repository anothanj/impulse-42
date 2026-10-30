# Projektdokumentation: Impulse42

**Lehrveranstaltung:** Game & XR Design  
**Engine:** Godot Engine 4.7 (2D)  
**Projekt:** Impulse42 – Physikbasiertes *Sumo Ring-Out* Tower Defense  

---

## 1. Game Design Sheet

### 1.1 Spielidee & Zielgruppe
*Impulse42* interpretiert das klassische Tower-Defense-Genre ohne Lebenspunkte oder Schadenszahlen neu. Im Zentrum einer schwebenden Steinplattform im leeren Raum (*Void*) ruht ein beweglicher, `65 kg` schwerer Energiekern (*Kernel*). Anrückende Gegnerwellen versuchen nicht, den Kern zu „zerstören“, sondern ihn durch kontinuierlichen physikalischen Schub über eine der vier ungesicherten Plattformkanten in den Abgrund zu drücken.

Der Spieler verteidigt den Kern ausschließlich über **Impulsübertragung ($p = m \cdot v$) und elastische Reflexion**: Mit Credits werden gerichtete Schlagkolben (**Vector Pistons**) und elastische Prellböcke (**Kinetic Bumpers**) auf dem Kachel-Grid platziert, um Angreifer aus ihrer Bahn zu werfen und selbst über die Plattformkante zu katapultieren.

**Zielgruppe:** Spielerinnen und Spieler, die kompakte Taktik- und Physik-Spiele (z. B. *Into the Breach* kombiniert mit Pinball-/Sumo-Mechaniken) sowie emergente Kettenreaktionen schätzen.

### 1.2 Core Gameplay Loop
1. **Vorbereitung & Bau:** Vor und während einer Welle platziert der Spieler Türme auf freien Kacheln der Plattform und richtet **Pistons** im 90°-Raster auf die erwarteten Angriffsrichtungen aus (markiert durch Warnpfeile am Rand).
2. **Wellen-Ansturm:** Über **5 aufeinanderfolgende Wellen** erscheinen schnelle **Pusher** und deutlich schwerere **Juggernauts** an wechselnden Seiten der Plattform und schieben kontinuierlich Richtung Kernel.
3. **Kinetische Abwehr:** **Bumpers** wirken wie Prellpilze im Flipper und schleudern Gegner bei Berührung seitlich weg, während **Pistons** Gegner (und bei falscher oder gezielter Ausrichtung auch den Kernel selbst) mit einem kräftigen Stoß nach vorne katapultieren.
4. **Ring-Out, Zeitlimit & Credits:** Fällt ein Gegner über den Rand ins Void, gibt es sofort Credits für neue Türme. Zusätzlich hat jede Welle ein festes Zeitlimit: Hält man den Kernel bis zum Ablauf der Zeit auf der Plattform (oder wirft vorher alle Gegner hinunter), ist die Welle geschafft und bringt einen Wellen-Bonus.
5. **Verschiebung & Zermalmen:** Der Kernel bleibt nach Zusammenstößen verschoben liegen. Rollt er gegen eigene Türme, zermalmt er diese durch sein Gewicht – man kann ihn also nicht einfach einmauern, sondern muss gefährdete Kanten immer wieder neu absichern.

### 1.3 Steuerung

| Eingabe | Funktion |
| :--- | :--- |
| **`1` / `2`** oder Klick im HUD | Turmtyp wählen: `[1] Piston` (50 Credits) / `[2] Bumper` (25 Credits) |
| **`R`** | Ghost-Vorschau des Pistons um 90° rotieren |
| **Linke Maustaste** | Turm auf gültiger Kachel platzieren (Grün = frei/bezahlbar, Rot = blockiert) |
| **Rechte Maustaste** | Ghost-Vorschau ein-/ausblenden |
| **`Leertaste`** oder *Start Wave* | Nächste Gegnerwelle starten |

---

## 2. Technische Architektur

### 2.1 Technologie-Entscheidung (Godot Engine 4.7 – 2D)
Godot 4.7 wurde gewählt, da die integrierte 2D-Physik-Engine (`RigidBody2D`, `StaticBody2D`, `Area2D`, `PhysicsMaterial`) sowie das szenen- und signalbasierte Node-System exakt auf das *Pure-Physics*-Konzept zugeschnitten sind. Durch Deaktivierung der globalen 2D-Gravitation (`default_gravity_vector = Vector2(0, 0)`) agiert die gesamte Szene als reibungsgedämpfte Top-Down-Ebene.

### 2.2 Szenen-Struktur & Komponenten
Das Projekt vermeidet monolithische Skripte sowie globale Singletons (Autoloads). Jede Spieleinheit ist eine gekapselte Szene in `scenes/` mit einem fokussierten Skript in `scripts/` (5 bis max. 100 Zeilen Code):

```text
Game (Node2D) — scenes/game.tscn
├── Camera2D              # Zentriert das Arena-Plateau zwischen TopBar und BottomBar
├── TileMapLayer          # 28×15 Kachel-Raster (Grid-zu-Welt-Umrechnung für Platzierung)
├── Kernel                # Instanz von kernel.tscn (RigidBody2D, 65 kg, zermalmt Türme bei Kontakt)
├── Enemies               # Laufzeit-Container für gespawnte Pusher & Juggernauts
├── Defenders             # Laufzeit-Container für platzierte Pistons & Bumpers
├── Boundaries            # Area2D-Triggerzone der Plattform; erkennt Ring-Outs via body_exited
├── WaveSpawner           # Steuert Wellen-Queue via SpawnTimer (Timer) & 8 Marker2D-Spawnpunkten
├── HUD                   # Instanz von hud.tscn (CanvasLayer für Credits, Welle, Bau-Menü & Endscreen)
├── PlacementManager      # Grid-Snapping, Bauvalidierung, Ghost-Preview & Instanziierung
└── GameManager           # Schlanke Zustandsmaschine (BUILDING, WAVE_ACTIVE, ENDED) & Ökonomie
```

**Wiederverwendung durch Szenen-Komposition:**
* Sowohl `pusher.tscn` als auch `juggernaut.tscn` teilen sich dasselbe Gegner-Skript (`scripts/pusher.gd`) und unterscheiden sich nur über ihre im Editor eingestellten Werte (Masse, Schubkraft, Geschwindigkeit, Credit-Wert).
* Auch `piston.tscn` und `bumper.tscn` folgen demselben Aufbau (`StaticBody2D` + Sensor-`Area2D` + `CooldownTimer`): Während der Piston gerichtet auf die Nachbarkachel schlägt, stößt der Bumper Gegner in alle Richtungen vom Mittelpunkt weg.

### 2.3 Physik-Layer & Entkopplung über Signale
Anstatt Kollisionen im Code über String- oder Typabfragen zu filtern, nutzt das Projekt dedizierte **2D-Physik-Layer** in `project.godot`:

| Layer | Name | Zugewiesene Nodes | Kollisionsmaske (`collision_mask`) |
| :---: | :--- | :--- | :--- |
| **1** | `Towers` | `Piston`, `Bumper` (`StaticBody2D`) | `0` (passiv) |
| **2** | `Kernel` | `Kernel` (`RigidBody2D`) | Layer 1 + 3 (`Towers` & `Enemies`) |
| **3** | `Enemies` | `Pusher`, `Juggernaut` (`RigidBody2D`) | Layer 1 + 2 + 3 (`Towers`, `Kernel`, `Enemies`) |
| – | *(Sensor)* | `Piston/TriggerArea` (`Area2D`) | Layer 2 + 3 (`Kernel` & `Enemies`) – schubst Gegner und Kernel |
| – | *(Sensor)* | `Bumper/BumpArea` (`Area2D`) | Nur Layer 3 (`Enemies`) |
| – | *(Sensor)* | `Boundaries` (`Area2D`) | Layer 2 + 3 (`Kernel` & `Enemies`) – ignoriert statische Türme |

Die Kommunikation zwischen den Systemen erfolgt entkoppelt über **Godot-Signale** (direkt in den `.tscn`-Dateien verdrahtet):
* `Boundaries` emittiert `enemy_fell(credits)` und `kernel_fell` an den `GameManager`.
* `WaveSpawner` überwacht lebende Gegner über deren `tree_exited`-Signal und meldet `wave_cleared` an den `GameManager`.
* `GameManager` informiert das `HUD` ausschließlich per Signal (`credits_changed`, `wave_changed`, `game_ended`) – er besitzt keine direkte Referenz auf UI-Elemente.

---

## 3. Learnings & Challenges

### Was gut funktioniert hat
* **Spannendes Gameplay aus einfachen Physik-Regeln:** Sobald Gewicht, Reibung und Stoßkraft zusammenpassten, ergaben sich ganz von selbst coole Spielmomente – etwa wenn ein Gegner schräg von einem Bumper abprallt und direkt vor einem Piston landet, der ihn über die Kante schlägt.
* **Sauberer Aufbau mit Godot-Nodes:** Die Aufteilung in kleine, eigenständige Szenen sowie die Nutzung von Godots eingebauten Werkzeugen (Timer-Nodes, Spawnpunkte in der Szene, Kollisions-Layer und Signale) hat das Projekt übersichtlich und leicht anpassbar gehalten.

### Hürden & Learnings bei der Umsetzung
* **Weniger ist mehr (Fokus statt Feature-Überladung):** Zwischendurch waren deutlich mehr Features geplant (vier verschiedene Türme, mehr Gegnertypen, Verkaufsfunktion und Pausenmodus). Dadurch überlappten sich die Aufgaben der Türme, und das Spiel wurde unübersichtlich und fehleranfällig. Das bewusste Kürzen auf zwei klar getrennte Türme (**Piston** und **Bumper**) sowie zwei Gegnergewichte (**Pusher** und **Juggernaut**) war der wichtigste Schritt zu einem runden Prototyp.
* **Idee auf dem Papier vs. Verhalten in der Engine:** Ursprünglich sollte der Bumper Gegner rein passiv wie ein elastisches Gummiband abprallen lassen. Im Spiel zeigte sich aber, dass Godot die Abprallstärke nach oben begrenzt – Gegner, die dauerhaft anschieben, blieben fast ohne Wirkung daran hängen. Erst als der Bumper wie im Flipper einen eigenen kurzen Stoß bekam, fühlte er sich richtig gut an.
* **Physik-Balancing & unerwartete Spielsituationen:** Da es keine Lebenspunkte gibt, verhielten sich manche Runden beim Testen anders als gedacht: Schoben Gegner von zwei Seiten gleichzeitig in der Mitte, bewegte sich kaum noch etwas und die Runde endete im „Unentschieden“. Außerdem ließ sich der Kern anfangs einfach mit Türmen zubauen, sodass er nicht mehr herunterfallen konnte. Durch ein **Zeitlimit pro Welle** und die Regel, dass der schwere Kern berührte Türme **zermalmt** (bzw. selbst von Pistons gestoßen werden kann), wurden beide Probleme spielerisch sinnvoll gelöst.
* **Ausrichtung auf dem Kachel-Raster:** Da der Piston beim Zuschlagen auf die Nachbarkachel hinausragt, stimmten Drehpunkt und Platzierung auf dem Grid anfangs nicht sauber überein. Erst durch das klare Trennen von Standfläche und Schlagbereich ließ er sich in alle vier Richtungen passend platzieren.

---

## 4. Quellenverzeichnis

Alle verwendeten Werkzeuge, Farbpaletten und Assets sind nachfolgend vollständig ausgewiesen:

* **Game Engine:**  
  * **Godot Engine v4.7** – Open-Source Game Engine, veröffentlicht unter der [MIT-Lizenz](https://godotengine.org/license/).
* **Grafik-Erstellung & Farbpalette (Eigenleistung / Open-Source-Tools):**  
  * **LibreSprite** – Open-Source Pixel-Art-Editor (GPLv2), genutzt zur Erstellung der eigenen Sprites und Kacheln (`assets/kernel.png`, `assets/piston-sheet.png`, `assets/pusher.png`, `assets/stone_tiles.png`).  
  * **DawnBringer 32 (DB32) Color Palette** – 32-Farben-Palette von Richard „DawnBringer“ Fhager ([Lospec DB32](https://lospec.com/palette-list/dawnbringer-32), frei verwendbar).  
  * **Platzhalter-Pixel-Art (`assets/bumper.png`, `assets/juggernaut.png`):** Eigens für den Prototyp KI-generierte `32×32`-Pixel-Art-Sprites.
* **Schriftarten & Audio:**  
  * Es wird ausschließlich die in Godot 4 integrierte Standard-Schriftart (Open-Source, MIT/OFL innerhalb der Engine) verwendet; es wurden keine externen Audio- oder Drittanbieter-Bibliotheken eingebunden.