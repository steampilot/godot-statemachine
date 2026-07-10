# Caprica Animationen - Übersicht

Diese Datei dokumentiert alle verfügbaren Animationen für den Caprica Player Character.

**Wichtig:** Diese Animationen sind PLAYER-exklusiv. Enemies werden ein reduziertes Animations-Set erhalten.

## Verwendung

### In GDScript mit IntelliSense:
```gdscript
# Statt:
sprite.play("idle")

# Verwende:
sprite.play(PLAYER.IDLE)

# Oder prüfe ob Animation loopt:
if PLAYER.is_looping(PLAYER.PUNCH):
    print("Diese Animation loopt!")

# Oder hole die Dauer:
var duration = PLAYER.get_duration(PLAYER.KICK_HIGH)
```

### Future: Enemy Animationen
```gdscript
# Enemies werden ein separates System bekommen:
# sprite.play(ENEMY.IDLE)
# sprite.play(ENEMY.WALK)
# sprite.play(ENEMY.ATTACK)
```

## Verfügbare Animationen (23 Total)

### 🚶 Bewegung (Movement) - 9 Animationen

| Konstante | Name | Frames | FPS | Loop | Verwendung |
|-----------|------|--------|-----|------|------------|
| `IDLE` | idle | 4 | 4 | ✓ | Basis-Idle (Breathing) |
| `IDLE_FIGHT_STANCE` | idle_fight_stance | 8 | 8 | ✓ | Kampf-Bereit Stance |
| `WALK` | walk | 6 | 8 | ✓ | Normal Walking East |
| `WALK_ANGRY` | walk_angry | 8 | 8 | ✓ | Sad/Angry Walk East |
| `WALK_HURT` | walk_hurt | 8 | 5 | ✓ | Verletztes Gehen |
| `WALK_NORTH` | walk_north | 6 | 8 | ✓ | Walking North |
| `WALK_SOUTH` | walk_south | 6 | 5 | ✓ | Walking South |
| `RUN` | run | 8 | 8 | ✓ | Schnelles Laufen |
| `RUN_SLIDE` | run_slide | 6 | 5 | ✗ | Running Slide |

### 🦘 Jump & Air Movement - 4 Animationen

| Konstante | Name | Frames | FPS | Loop | Verwendung |
|-----------|------|--------|-----|------|------------|
| `JUMP_UP` | jump_up | 3 | 8 | ✗ | Sprung nach oben |
| `JUMP_TOP` | jump_top | 2 | 2 | ✗ | Höchster Punkt |
| `JUMP_DOWN` | jump_down | 2 | 2 | ✗ | Fallen |
| `JUMP_LAND` | jump_land | 3 | 4 | ✗ | Landung |

### 🦵 Combat - Kicks - 3 Animationen

| Konstante | Name | Frames | FPS | Loop | Damage Frames |
|-----------|------|--------|-----|------|---------------|
| `KICK_HIGH` | kick_high | 7 | 8 | ✗ | Frame 3-5 |
| `KICK_MID` | kick_mid | 6 | 6 | ✗ | Frame 2-4 (Flying Kick) |
| `KICK_LOW` | kick_low | 7 | 8 | ✗ | Frame 3-5 (Leg Sweep) |

### 👊 Combat - Punches - 2 Animationen

| Konstante | Name | Frames | FPS | Loop | Damage Frames |
|-----------|------|--------|-----|------|---------------|
| `PUNCH` | punch | 6 | 8 | ✗ | Frame 2-4 (Lead Jab) |
| `PUNCH_UP` | punch_up | 7 | 5 | ✓ | Frame 3-5 (Uppercut) |

### ✨ Special Actions - 3 Animationen

| Konstante | Name | Frames | FPS | Loop | Verwendung |
|-----------|------|--------|-----|------|------------|
| `DASH` | dash | 6 | 6 | ✗ | Schnelles Dash/Front Flip |
| `LADDER_GRAB` | ladder_grab | 7 | 8 | ✓ | Leiter klettern |
| `GUITAR_STRUM` | guitar_strum | 8 | 8 | ✗ | PowerChord Guitar Attack! |

### 💔 Damage & Death - 2 Animationen

| Konstante | Name | Frames | FPS | Loop | Verwendung |
|-----------|------|--------|-----|------|------------|
| `HURT` | hurt | 6 | 6 | ✓ | Damage Reaktion |
| `DYING` | dying | 7 | 8 | ✗ | Tod Animation |

## Animation Groups

Für einfachere Verwaltung gibt es vordefinierte Gruppen:

```gdscript
ANIMATIONS.MOVEMENT_ANIMATIONS    # Alle Walk/Run Animationen
ANIMATIONS.IDLE_ANIMATIONS        # Alle Idle Varianten
ANIMATIONS.JUMP_ANIMATIONS        # Alle Jump Phasen
ANIMATIONS.KICK_ANIMATIONS        # Alle Kicks
ANIMATIONS.PUNCH_ANIMATIONS       # Alle Punches
ANIMATIONS.COMBAT_ANIMATIONS      # Kicks + Punches kombiniert
ANIMATIONS.SPECIAL_ANIMATIONS     # Dash, Ladder, Guitar
ANIMATIONS.DAMAGE_ANIMATIONS      # Hurt + Dying
```

## Beispiel-Code

### Basis Animation abspielen
```gdscript
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
    sprite.play(PLAYER.IDLE)
```

### Animation mit Duration berechnen
```gdscript
func play_attack() -> void:
    sprite.play(PLAYER.KICK_HIGH)
    var attack_duration = PLAYER.get_duration(PLAYER.KICK_HIGH)
    await get_tree().create_timer(attack_duration).timeout
    sprite.play(PLAYER.IDLE)
```

### Zufällige Combat Animation
```gdscript
func random_combat_move() -> void:
    var combat_anims = PLAYER.COMBAT_ANIMATIONS
    var random_anim = combat_anims[randi() % combat_anims.size()]
    sprite.play(random_anim)
```

### Prüfen ob Animation fertig (non-looping)
```gdscript
func _on_sprite_animation_finished() -> void:
    if not PLAYER.is_looping(sprite.animation):
        sprite.play(PLAYER.IDLE)
```

## Asset-Quellen

Alle Animationen basieren auf den Caprica Sprite Sheets in:
```
res://Assets/Characters/Caprica_Sprites/animations/
```

### Mapping:
- **dash** → front-flip/east
- **dying** → falling-back-death/east
- **guitar_strum** → pull-heavy-object/south (PowerChord-sheet.png)
- **hurt** → taking-punch/east
- **idle** → breathing-idle/south-east
- **idle_fight_stance** → fight-stance-idle-8-frames/south-east
- **jump_*** → jumping-1/east
- **kick_high** → high-kick/east
- **kick_low** → leg-sweep/east
- **kick_mid** → flying-kick/east
- **ladder_grab** → two-footed-jump/north
- **punch** → lead-jab/east
- **punch_up** → surprise-uppercut/east
- **run** → running-8-frames/east
- **run_slide** → running-slide/south-east
- **walk** → walking-10/east
- **walk_angry** → sad-walk/east
- **walk_hurt** → sad-walk/south-east
- **walk_north** → walk/north
- **walk_south** → walk/south

## State Machine Integration

Die aktuellen States verwenden bereits einige dieser Animationen:

```gdscript
JumpState   → animation_name = "jump_up"
IdleState   → animation_name = "idle"
FallState   → animation_name = "jump_down"
RunState    → animation_name = "run"
AttackState → animation_name = "attack" (⚠️ existiert nicht, sollte PUNCH/KICK sein)
DashState   → animation_name = "dash"
HurtState   → animation_name = "hurt"
DyingState  → animation_name = "dying" (in dying_state.tscn)
LadderGrabState → animation_name = "ladder_grab"
```

## Todo / Verbesserungen

- [ ] `AttackState` muss auf `PUNCH`, `KICK_HIGH`, `KICK_MID` oder `KICK_LOW` umgestellt werden
- [ ] Combo-System für Attack Chains implementieren
- [ ] `GUITAR_STRUM` als Power-up Attack integrieren
- [ ] `WALK_ANGRY` und `WALK_HURT` für Story-Momente verwenden
- [ ] Directional Animations (North/South) im Movement System integrieren
- [ ] `RUN_SLIDE` als Crouch-Run-Mechanik nutzen
- [ ] Enemy Animation System erstellen (ENEMY.gd global mit reduziertem Set)

## Namespace-Struktur

```
PLAYER.* = Caprica Player Animationen (23 total)
├── Movement (9)
├── Jump (4)
├── Combat (5)
├── Special (3)
└── Damage (2)

ENEMY.* = Enemy Animationen (Future - reduziertes Set)
├── IDLE
├── WALK
├── ATTACK
├── HURT
└── DYING
```

## Technische Details

- **Sprite Größe:** 48x48 pixels pro Frame
- **Atlas Format:** Horizontale Sprite Sheets
- **Engine:** Godot 4.3+
- **AnimatedSprite2D** Node in `player.tscn`

---

**Letzte Aktualisierung:** 29. Januar 2026  
**Autor:** Jérôme (Steampilot)  
**Projekt:** CapricaGame - 2D Platformer
