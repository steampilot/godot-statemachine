# Globale Singletons (Autoload)

Alle Komponenten sind als **Autoload Singletons** konfiguriert und können überall im Projekt mit `MAIN.`, `HEALTH.`, etc. direkt angesprochen werden.

## MAIN.gd
**Zentrale Game-Management**

Verwaltet:
- Player-Referenz
- UI-Root
- Game States
- Scores & Items
- Pause-State

```gdscript
# Beispiele
MAIN.add_score(100)
MAIN.collect_item()
MAIN.toggle_pause()
MAIN.set_player(player_node)
```

---

## HEALTH.gd
**Universelles Entity Health Management**

Verwaltet Gesundheit für **alle Entities**: Player, Enemies, Doors, Locks, Barrels, etc.

Jede Entity registriert sich mit eindeutiger ID und erhält eigene Health-Verwaltung:

```gdscript
# Entity registrieren
HEALTH.register_entity("player_1", player_node, 100)
HEALTH.register_entity("enemy_goblin_1", goblin_node, 30)
HEALTH.register_entity("door_boss_1", door_node, 50, func(): print("Door destroyed"))
HEALTH.register_entity("barrel_explosive_1", barrel_node, 1)

# Schaden austeilen
HEALTH.deal_damage("enemy_goblin_1", 10)
HEALTH.deal_damage("player_1", 5)

# Heilen
HEALTH.heal_entity("player_1", 20)

# Abfragen
HEALTH.get_health("enemy_goblin_1")           # 20 (30 - 10)
HEALTH.get_max_health("enemy_goblin_1")       # 30
HEALTH.get_health_percent("enemy_goblin_1")   # 66.67
HEALTH.is_alive("enemy_goblin_1")             # true

# Spezial-Features
HEALTH.set_invulnerable("player_1", 2.0)      # 2 Sekunden unverwundbar
HEALTH.set_damage_reduction("player_1", 0.5)  # 50% Schadensreduktion

# Gegner zählen
HEALTH.count_alive_entities("enemy_")         # Alle "enemy_*" Gegner
HEALTH.get_alive_entities("enemy_")           # Array aller lebenden enemy_ Entities

# Entfernen
HEALTH.unregister_entity("barrel_explosive_1")
```

**Features:**
- Entity-Registry mit eindeutigen IDs
- Damage Reduction pro Entity
- Invulnerabilität mit Duration
- Optional: Callback bei Tod
- Generische Signals für alle Entities

**Signals:**
- `health_changed(entity_id, current, max)`
- `entity_damaged(entity_id, damage, remaining_health)`
- `entity_healed(entity_id, amount, new_health)`
- `entity_died(entity_id, entity_ref)`
- `entity_registered(entity_id)`
- `entity_unregistered(entity_id)`

---

## LEVEL_LOADER.gd
**Level & Szenen-Verwaltung**

Verwaltet:
- Levels laden/entladen
- Level-Navigation
- Szenen-Zuordnung

```gdscript
# Beispiele
LEVEL_LOADER.load_level(1)
LEVEL_LOADER.next_level()
LEVEL_LOADER.restart_level()
LEVEL_LOADER.add_level(2, "res://scenes/level_2.tscn")
```

**Signals:**
- `level_loaded(level, scene_name)`
- `level_unloaded(level)`

---

## UTILS.gd
**Utility-Funktionen**

Verschiedenste Hilfsfunktionen:
- Distanz/Richtungs-Berechnungen
- Geometrie-Checks
- String-Operations
- Konvertierungen

```gdscript
# Beispiele
UTILS.distance_between(pos1, pos2)
UTILS.direction_to(from, to)
UTILS.clamp_value(value, 0, 100)
UTILS.point_in_rect(point, rect)
UTILS.random_color()
```

---

## AUDIO.gd
**Audio-Management**

Verwaltet:
- Musik spielen/stoppen
- Sound Effects (SFX)
- Volume-Kontrolle
- Audio-Buses

```gdscript
# Beispiele
AUDIO.play_music("res://audio/music.ogg")
AUDIO.play_sfx("res://audio/jump.wav", "jump_sfx")
AUDIO.set_music_volume(0.8)
AUDIO.set_sfx_volume(0.9)
AUDIO.mute_audio()
```

**Signals:**
- `volume_changed(bus_name, volume)`
- `music_started(track_name)`
- `music_stopped`

---

## SCENE_TRANSITION.gd
**Szenen-Übergänge & Fade-Effekte**

Verwaltet:
- Fade In/Out
- Übergänge mit Callbacks
- Transition-Speed

```gdscript
# Beispiele
SCENE_TRANSITION.fade_out()
SCENE_TRANSITION.fade_in()
SCENE_TRANSITION.fade_transition(func(): load_new_scene())
SCENE_TRANSITION.set_transition_speed(1.0)
SCENE_TRANSITION.instant_black()
```

**Signals:**
- `transition_started`
- `transition_completed`

---

## Aktivierung in project.godot

```
[autoload]
MAIN="*res://src/globals/MAIN.gd"
HEALTH="*res://src/globals/HEALTH.gd"
LEVEL_LOADER="*res://src/globals/LEVEL_LOADER.gd"
UTILS="*res://src/globals/UTILS.gd"
AUDIO="*res://src/globals/AUDIO.gd"
SCENE_TRANSITION="*res://src/globals/SCENE_TRANSITION.gd"
```

Das Asterisk `*` vor dem Pfad signalisiert: **Node wird automatisch der Scene Tree hinzugefügt**
