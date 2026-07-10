# Run Slide State - Dokumentation

## Übersicht
Der **RunSlideState** ist ein verschachtelter State unter dem RunState, der einen schnellen Bodenstoß (Slide) implementiert. Wenn Caprica während des Rennens die Attack-Taste drückt, führt sie einen kraftvollen Slide aus, der sie bis zu einer bestimmten Distanz nach vorne bewegt.

## Aktivierung
- **Trigger:** Attack-Taste während RunState (auf dem Boden rennend)
- **Parent State:** RunState (verschachtelter State)
- **Animation:** "run_slide"

## Verhalten

### Slide-Mechanik
1. **Richtung:** Basiert auf der aktuellen Sprite-Richtung (flip_h)
2. **Geschwindigkeit:** Konfigurierbar über `slide_speed` (Standard: 300.0)
3. **Maximale Distanz:** `slide_max_distance` (Standard: 200.0 Pixel)
4. **Dauer:** `slide_duration` (Standard: 0.5 Sekunden)

### Kollisionserkennung
Der State nutzt den **SlideSensor** (RayCast2D), um Hindernisse zu erkennen:
- Sendet einen Raycast in Slide-Richtung
- Erkennt Wände, Gegner und andere Hindernisse (collision_mask: 21)
- Stoppt den Slide bei Kollision

### Exit-Bedingungen
Der Slide endet, wenn eine der folgenden Bedingungen eintritt:

1. **Hindernis getroffen** - SlideSensor erkennt Kollision
2. **Maximale Distanz erreicht** - `slide_max_distance` überschritten
3. **Timer abgelaufen** - `slide_duration` überschritten
4. **Vom Boden gefallen** - Player ist nicht mehr `is_on_floor()`

### Transitionen
Nach dem Slide:
- **Auf dem Boden + Bewegungsinput:** → RunState
- **Auf dem Boden + kein Input:** → IdleState
- **In der Luft:** → FallState

## Technische Details

### Slope Handling
- `floor_stop_on_slope = false` - Verhindert Stoppen auf Abhängen
- `floor_constant_speed = true` - Hält konstante Geschwindigkeit
- `gravity_multiplier = 0.1` - Minimale Gravität für Bodenhaftung

### SlideSensor Konfiguration
```gdscript
Position: Vector2(0, -21)  # Auf Caprica's Höhe
Target Position: Dynamisch basierend auf slide_direction und slide_max_distance
Collision Mask: 21 (Wände, Enemies, etc.)
```

## Export-Variablen
```gdscript
@export var slide_speed: float = 300.0        # Slide-Geschwindigkeit
@export var slide_max_distance: float = 200.0 # Maximale Slide-Distanz
@export var slide_duration: float = 0.5       # Maximale Slide-Dauer
@export var min_slide_distance: float = 20.0  # Mindest-Distanz vor Kollisionsprüfung
@export var ghost_spawn_interval: float = 0.05 # Intervall zwischen Ghost-Spawns
@export var ghost_enabled: bool = true        # Ghost-Trail aktiviert?
```

## Ghost Trail System

### Visueller Feedback
Der Slide erzeugt einen **Motion Trail** aus Ghost-Sprites:
- Ghost-Image wird am Start-Punkt gespawnt
- Weitere Ghosts alle 0.05 Sekunden während des Slides
- Ghosts verblassen über 0.4 Sekunden
- Leicht bläuliche Tönung für Geschwindigkeitseffekt

### Ghost Sprite Eigenschaften
- Kopiert aktuelles Sprite-Frame von Caprica
- Behält Flip-Richtung und Position
- Verblasst automatisch (Alpha: 0.5 → 0.0)
- Löscht sich selbst nach Fade-Out

### Anpassung
```gdscript
ghost_spawn_interval: 0.05  # Mehr Ghosts = dichter Trail
ghost_enabled: false        # Trail komplett deaktivieren
```

Im **ghost_sprite.gd**:
```gdscript
fade_duration: 0.4         # Wie lange Ghost sichtbar bleibt
initial_opacity: 0.5       # Start-Transparenz
```

## Code-Architektur
Der State folgt dem **Second Life State Machine Stil**:
- Erbt von `State` Basisklasse
- Nutzt `enter()`, `exit()`, `process_physics()` Lifecycle
- Kommuniziert über `states` Dictionary
- Keine direkte Kopplung an andere States

## Integration

### State Machine Hierarchie
```
StateMachine
├── IdleState
├── RunState
│   └── RunSlideState  ← Nested State
├── JumpState
├── FallState
└── ...
```

### Wichtige Änderungen
1. **StateMachine:** `_collect_states()` sammelt nun auch verschachtelte States
2. **RunState:** Prüft bei Attack-Input zuerst auf `run_slide`, dann auf `attack`
3. **Player:** Neue `@onready var slide_sensor` Referenz
4. **player.tscn:** SlideSensor als `unique_name_in_owner` markiert

## Verwendung

### Im Editor
1. Animation "run_slide" muss in SpriteFrames definiert sein
2. SlideSensor ist bereits konfiguriert
3. Export-Variablen können im Inspector angepasst werden

### Tuning-Tipps
- **Längerer Slide:** `slide_max_distance` erhöhen
- **Schnellerer Slide:** `slide_speed` erhöhen
- **Kürzerer Slide:** `slide_duration` reduzieren
- **Mehr Kontrolle:** `gravity_multiplier` anpassen

## Debug
Der State gibt folgende Ausgaben:
```
"Entered Run Slide State"
"Slide direction: X, max distance: Y"
"Slide hit obstacle: [Name]"
"Slide ended: [Grund] (distance: [Distanz])"
```

## Future Enhancements
Mögliche Erweiterungen:
- Damage beim Slide (Kollision mit Enemies)
- Partikel-Effekte während des Slides
- Sound-Effekte
- Variable Geschwindigkeit basierend auf Momentum
- Jump-Cancel Option
