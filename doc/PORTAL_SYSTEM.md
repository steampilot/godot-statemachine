## Portal & Spawnpoint System

Ein **Portal** ist ein Übergangspunkt zwischen zwei Orten:
- Zu einem anderen **Spawnpoint im gleichen Level**
- Zu einem **Spawnpoint in einem anderen Level**

### Komponenten

#### 1. **SpawnPoint** (spawn_point.gd)
Markiert eine Position, wo Spieler in ein Level eintreten oder respawnen können.

**Eigenschaften:**
- `spawn_id: String` - Eindeutige Bezeichnung dieses Spawnpoints (z.B. "spawn_default", "spawn_after_boss")

**Verwendung:**
- In Level-Szenen platzieren, um Eintrittspunkte zu definieren
- Eindeutige IDs für verschiedene Übergänge nutzen

#### 2. **Portal** (portal.gd)
Ein Area2D, das den Spieler zu einem Spawnpoint teleportiert.

**Eigenschaften:**
- `target_level_path: String`
  - Leer = Spawnpoint im gleichen Level
  - Gefüllt = Pfad zur neuen Level-Szene (z.B. "res://Scenes/level_1.tscn")

- `target_spawn_point_id: String` - ID des Ziel-Spawnpoints

- `auto_transition: bool` - Automatisch transportieren beim Betreten?

- `transition_delay: float` - Verzögerung vor dem Transport (sekunden)

**Verwendung:**
```gdscript
# Spawnpoint im gleichen Level
target_level_path = ""
target_spawn_point_id = "spawn_after_puzzle"

# Spawnpoint in anderem Level
target_level_path = "res://Scenes/level_1_2.tscn"
target_spawn_point_id = "spawn_entrance"
```

### Workflow

#### Level-Aufbau
```
Level 1
├── SpawnPoint (spawn_id="level_start")
├── Portal → Spawnpoint "puzzle_done" im gleichen Level
├── SpawnPoint (spawn_id="puzzle_done")
└── Portal → Spawnpoint "entrance" in Level 2

Level 2
├── SpawnPoint (spawn_id="entrance")
└── Portal → zurück zu "level_start" in Level 1
```

#### Integration mit LEVEL_LOADER

**Geplante Funktionen:**
```gdscript
# Level mit Spawnpoint laden
LEVEL_LOADER.load_level_with_spawn("res://Scenes/level_2.tscn", "entrance")

# Spieler im aktuellen Level teleportieren
player.teleport_to_spawn("puzzle_done")
```

### Implementation Roadmap

- [ ] SpawnPoint-Registry im Level verankern
- [ ] Player.teleport_to_spawn() implementieren
- [ ] Portal._spawn_at_point_in_level() vollenden
- [ ] LEVEL_LOADER.load_level_with_spawn() hinzufügen
- [ ] Portal._spawn_at_point_in_new_level() vollenden
- [ ] Transition-Animation hinzufügen (optional)
## Portal Teleport System
## Nahtlose Level- und Spawnpoint-Übergänge mit visueller Kontinuität

Ein **Portal** verbindet zwei räumliche Bereiche und ermöglicht Spieler-Teleportation mit echter visueller Kontinuität durch Puppeteering und Clipping.

### Architektur-Komponenten

#### 1. **Portal** (portal.gd)
Hauptklasse für Portal-Logik

**Konzept:**
```
[AREA_A]         [AREA_B]
  |               |
  Player --- PORTAL_A <---> PORTAL_B --- Puppet
  |               |
[sichtbar]    [CLIPPED]
```

**Ablauf:**
1. Player betritt **AREA_A** → Area2D triggers `_on_area_entered()`
2. Puppet wird an **paired_portal** (AREA_B) erstellt
3. Puppet wird mit `PuppetManager` unter Kontrolle gestellt
4. Beide sind synchron: Puppet spiegelt Player-Intent
5. Player bewegt sich zum Portal-Crossing:
   - Player wird via `PortalClipping` sichtbar gerendert (LEFT oder RIGHT)
   - Puppet wird gegenüber gerendert (Fade-Out Effekt)
6. Bei **Crossing** (Velocity-Richtung === Portal-Richtung):
   - **SWAP**: Position, Velocity, State tauschen
   - Puppet wird deaktiviert
   - Player läuft normal weiter in AREA_B
7. Optional: Level-Wechsel mit `LEVEL_LOADER.load_level()`

**Schnittstellen:**
```gdscript
@export var paired_portal: Portal           # Ziel-Portal
@export var target_spawn_point_id: String   # ID für Spawnpoint
@export var target_level_path: String       # Neues Level (leer=gleich)

signal player_entered_portal
signal player_exited_portal
signal portal_swap_completed
```

#### 2. **PortalClipping** (portal_clipping.gd)
Managed Rendering-Clipping für visuelle Kontinuität

**Features:**
- Shader-basiertes Clipping (smooth fade-out)
- Fallback CPU-Clipping (einfach, performant)
- Richtungs-based Rendering (LEFT/RIGHT)

**Shader-Logik:**
```glsl
// Fade Player aus wenn er Portal überschreitet
if (WORLD_VERTEX.x > portal_position.x) {  // RIGHT
    alpha *= (1.0 - fade_factor);
}
```

**Verwendung:**
```gdscript
var clipping = PortalClipping.new()
clipping.enable_clipping(portal_pos, "RIGHT")
# Player wird nur rechts des Portals sichtbar
# Mit smoothem Fade-Out über 50 Pixel
```

#### 3. **PuppetManager** (puppet_manager.gd)
Synchronisiert Puppet-Klone mit Original-Player

**Verantwortlichkeiten:**
- Tracking: Puppeteered-Status
- Intent-Spiegelung: Animation, Velocity, Direction
- Cleanup: Queue Puppet zur Deletion

**Puppeteering-State:**
```gdscript
var puppeteered: bool = false
var puppeteer: Object  # Portal-Referenz

func set_puppeteered(active: bool, puppeteer: Object)
func mirror_intent(original_player: Node2D)
```

#### 4. **PlayerPortalSupport** (player_portal_support.gd)
Komponente für Player-Integration

**Bietet Schnittstelle zu:**
- PortalClipping
- PuppetManager

**Verwendung in Player:**
```gdscript
# In player.gd hinzufügen:
@onready var portal_support = $PlayerPortalSupport

func _ready() -> void:
    # Portal-Support ist bereit
    pass
```

### Integration in Player

**Schritt 1:** PlayerPortalSupport-Node zu Player-Scene hinzufügen

**Schritt 2:** In Player.gd verwenden:
```gdscript
func _physics_process(delta: float) -> void:
    # ... existing code ...

    # Wenn Puppet: Keine normale Input-Verarbeitung
    if portal_support.is_puppeteered():
        return

    # Normaler Spieler-Betrieb
    _process_input()
    move_and_slide()
```

### Level-Setup

**Level-Struktur Beispiel:**
```
Level1 (res://Scenes/level_1.tscn)
├── SpawnPoint (spawn_id="start")
├── Portal_A
│   └── paired_portal: Portal_B (in Level1)
│   └── target_spawn_point_id: ""
│   └── target_level_path: ""
├── SpawnPoint (spawn_id="to_level2")
├── Portal_B
│   └── paired_portal: Portal_A
└── Portal_Exit
    └── paired_portal: Portal_Entry (in Level2)
    └── target_spawn_point_id: "entrance"
    └── target_level_path: "res://Scenes/level_2.tscn"

Level2 (res://Scenes/level_2.tscn)
└── Portal_Entry
    └── paired_portal: Portal_Exit (in Level1)
    └── target_spawn_point_id: "start"
    └── target_level_path: "res://Scenes/level_1.tscn"
```

### Performance-Tipps

1. **Shader vs CPU-Clipping:**
   - Shader: Besser für viele Portale gleichzeitig
   - CPU: Einfacher zu debuggen, genügend für 1-2 Portale

2. **Puppet-Duplikation:**
   - Verwendet `duplicate()` → vollständiger Klon
   - Disables Input-Processing via `puppeteered`-Flag

3. **Garbage Collection:**
   - Puppet wird via `queue_free()` nach Swap gelöscht
   - Verhindert Memory-Leaks bei häufigen Portals

### Zukünftige Erweiterungen

- [ ] Portal-Animation/Effekte (Glow, Distortion)
- [ ] Multi-Portal-Netzwerke (Netzwerk von verbundenen Portals)
- [ ] Portal-Physics: Objekte können auch durch Portale)
- [ ] Portal-Rätsel: Schalter, die Portale aktivieren/deaktivieren
- [ ] Bi-direktionale Portal-Übergänge mit verschiedenen Spawn-IDs
