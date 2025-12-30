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
