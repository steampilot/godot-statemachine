# DOCKING SYSTEM DETAILED

## Überblick

Das **Docking System** ist eine Semi-automatische Bewegungsmechanik, bei der der Spieler über Distanz zu einem Gegner "gezogen" wird, wenn ein Attack Intent aus zu großer Entfernung ausgelöst wird. Dies ermöglicht flüssige Combat-Übergänge und verhindert, dass Spieler durch "Zu-Weit-Weg" frustriert werden.

**Kern-Idee**: Statt "Dein Attack war zu weit weg, missglückt", wird Spieler automatisch näher gezogen (mittels Dash), um dann den Attack auszuführen. Das fühlt sich **natürlich, responsive und befriedigend** an.

---

## Design-Philosophie: Option B (Soft Docking)

Wir verwenden **Soft Docking** statt Hard Docking:

| Aspekt | Hard Docking | Soft Docking (gewählt) |
|--------|-------------|----------------------|
| Auto-Pull | Sofort, instant | Sichtbar, mit Dash-Animation |
| Gegner-Kontrolle | Gegner ist "locked" | Gegner kann noch fliehen |
| Spieler-Gefühl | Automatisch, unpersönlich | Agency—"Ich hab Gegner zugezogen" |
| Engagement | Weniger aktiv | Aktiv (Spieler erkennt sein Dash) |
| Escape-Chance | Keine | Ja (Gegner kann sich befreien) |

**Soft Docking** ist superior weil:
1. Spieler sieht sein Dash—fühlt sich wie Kontrolle an
2. Gegner kann noch escapen—macht es fair und spannend
3. Combo-Fenster wird nicht zu leicht (Gegner muss managen)

---

## Mechanische Details

### Trigger-Bedingungen

Docking triggert wenn:
1. **Attack Intent wird ausgelöst** (Player drückt Attack-Button)
2. **Abstand zu Gegner > 300px** (Zu weit für direkten Hit)
3. **Gegner ist sichtbar/in Aggro-Range** (Nicht auf ganzer Map)
4. **Spieler ist nicht bereits docked** (Prevent Spam)

```gdscript
# res/combat/docking_system.gd

extends Node
class_name DockingSystem

const DOCK_DISTANCE_THRESHOLD: float = 300.0
const DOCK_SPEED: float = 500.0  # pixels per second
const DOCK_TIMEOUT: float = 1.0  # seconds before auto-release

var is_docking: bool = false
var docked_target: Node2D = null
var dock_timer: float = 0.0

func check_dock_needed(attacker: Node2D, target: Node2D) -> bool:
    if is_docking:
        return false  # Already docking

    var distance = attacker.global_position.distance_to(target.global_position)

    if distance > DOCK_DISTANCE_THRESHOLD:
        return true

    return false

func initiate_dock(attacker: Node2D, target: Node2D) -> void:
    if is_docking or not check_dock_needed(attacker, target):
        return

    is_docking = true
    docked_target = target
    dock_timer = 0.0

    # Trigger auto-dash towards target
    var direction = (target.global_position - attacker.global_position).normalized()
    attacker.trigger_dash(direction, DOCK_SPEED)

    # Emit signal for UI feedback
    docking_started.emit(target)
```

### Docking-Motion (Auto-Dash)

Statt normaler Dash-Logik, nutzen wir einen **spezialisierten Docking-Dash**:

```gdscript
# res/entities/Player.gd

func trigger_dash(direction: Vector2, speed: float = 500.0, is_dock: bool = false) -> void:
    var target_distance = 0

    if is_dock and docking_system.docked_target:
        # Dock-Dash: Move until at melee distance (50px)
        var target_pos = docking_system.docked_target.global_position
        target_distance = global_position.distance_to(target_pos) - 50.0
    else:
        # Normal Dash: Fixed distance
        target_distance = 300.0

    var dash_duration = target_distance / speed

    # Create tween for smooth dash
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(
        self,
        "global_position",
        global_position + direction * target_distance,
        dash_duration
    )

    # Audio feedback
    Audio.play_sfx("dash_whoosh")

    # Sprite animation
    sprite.play("dash")

    # After dash completes, execute attack
    await tween.finished

    if is_dock:
        docking_system.complete_dock(self)
```

### Gegner-Escape-Mechanik

Der gedockte Gegner ist nicht "stuck". Er kann:
1. **Angreifen** → Spieler bricht aus Dock ab
2. **Wegsprinten** → Breakup der Dock-Verbindung
3. **Sich Zeitlimit abwarten** (1.0s) → Auto-Release

```gdscript
# res/entities/Enemy.gd (Gegner mit Dock-Logik)

var is_docked_to_player: bool = false
var dock_breakup_timer: float = 0.0

func on_docked_to_player() -> void:
    is_docked_to_player = true
    dock_breakup_timer = 0.0

    # Visual feedback: Enemy flashes red when docked
    modulate = Color.RED

func _process(delta: float) -> void:
    if is_docked_to_player:
        dock_breakup_timer += delta

        # Timeout: auto-release if too long
        if dock_breakup_timer > 1.0:
            breakup_dock()
            return

        # Gegner kann durch Angriff breakup trigen
        if should_attack():
            attack_player()
            breakup_dock()

func breakup_dock() -> void:
    is_docked_to_player = false
    modulate = Color.WHITE

    # Small knockback away from player
    var away_direction = (global_position - player.global_position).normalized()
    velocity = away_direction * 200

func attack_player() -> void:
    # Attack while docked
    # This forces player to break dock or take hit
    player.take_damage(10)
    breakup_dock()
```

---

## Advanced Features

### Multi-Target Docking (Combo-Chain)

Wenn Spieler während Dock einen anderen Gegner attackiert:

```gdscript
# In DockingSystem

func on_attack_during_dock(attacker: Node2D, new_target: Node2D) -> void:
    # Check if new target is in range for combo-chain
    var distance_to_new_target = attacker.global_position.distance_to(new_target.global_position)

    if distance_to_new_target < 400:  # Combo-chain range
        # Release current dock, initiate new dock
        complete_dock(attacker)
        initiate_dock(attacker, new_target)
```

**Gameplay**: Spieler kann sich zu mehreren Gegnern "ziehen" und große Combos bauen.

### Docking + Knockback Interaction

Wenn Gegner während Dock angegriffen wird:

```gdscript
# res/combat/combat_engine.gd

func handle_attack_intent(intent: Intent, attacker: Node2D) -> void:
    var target = intent.data.get("target")

    if target.is_docked_to_player:
        # Docked enemies take EXTRA knockback
        var extra_knockback_multiplier = 1.5
        var knockback_force = 250 * extra_knockback_multiplier

        # Knockback breaks the dock
        target.apply_knockback(knockback_force)
        target.breakup_dock()
    else:
        # Normal attack
        target.apply_knockback(250)
```

**Impact**: Spieler muss timing wählen—dock halten für sicheren Hit, oder sofort attackieren für extra Knockback.

---

## Visual & Audio Design

### Docking Visual Feedback

```gdscript
# res/ui/DockingVFX.gd

extends Node2D
class_name DockingVFX

var connection_line: Line2D
var player: Node2D
var target: Node2D

func _ready() -> void:
    connection_line = Line2D.new()
    connection_line.width = 3.0
    connection_line.self_modulate = Color.LIGHT_BLUE
    add_child(connection_line)

func _process(_delta: float) -> void:
    if player and target:
        # Draw line from player to target
        connection_line.clear_points()
        connection_line.add_point(player.global_position)
        connection_line.add_point(target.global_position)

        # Pulse animation
        var pulse = sin(Time.get_ticks_msec() / 200.0) * 0.5 + 0.5
        connection_line.modulate.a = pulse
```

### Docking Audio Feedback

```gdscript
# In DockingSystem.initiate_dock()

# Tone indiciert Locking
Audio.play_sfx("dock_lock_tone")

# Continuous tone während docking
var dock_tone = Audio.play_looping("dock_maintain_tone")

# When breaking
Audio.play_sfx("dock_release_tone")
dock_tone.stop()
```

---

## Integration mit anderen Systemen

### Mit Combat System
Attack Intent > Check Distance > Initiate Dock > Dash Executes > Attack Fires > Combo Continues

### Mit Snap-to-Beat
Dock-Dash kann optional mit Beat synchronisiert werden:
```gdscript
# Optional: Dock-Dash startet auf nächstem Beat
var snap_delay = MusicPlayer.get_time_to_next_beat_ms()
if snap_delay < 50:
    await get_tree().create_timer(snap_delay / 1000.0).timeout
```

### Mit Knockback System
Docked Targets bekommen extra Knockback, brechen automatisch Dock ab.

### Mit Combo System
Multi-Target Docking ermöglicht Combo-Chains über mehrere Gegner.

---

## Best Practices

### Docking Distance
- **Too Short (< 200px)**: Docking fühlt sich unnötig an
- **Just Right (300px)**: Belohnend, aber nicht trivial
- **Too Long (> 500px)**: Fühlt sich unfair, schränkt Level-Design ein

### Docking Speed
- **Too Slow (< 300px/s)**: Docking fühlt sich träge an, unterbricht Flow
- **Just Right (500px/s)**: Schnell und respons, aber lesbar
- **Too Fast (> 800px/s)**: Schwer zu folgen visual, Gegner kann nicht escapen

### Docking Timeout
- **Too Short (< 0.5s)**: Gegner kann leicht escapen, zu viel Chaos
- **Just Right (1.0s)**: Gegner hat Chance, aber Spieler kann auch Moment nutzen
- **Too Long (> 1.5s)**: Gegner ist effectively "stunned", unfair

---

## Testing & Validation

### Mechanical Tests
- [ ] Docking triggert korrekt bei > 300px Distance
- [ ] Dash-Animation spielt während Docking
- [ ] Attack executes nach Dock completes
- [ ] Gegner kann Dock brechen durch Angriff
- [ ] Gegner kann Dock brechen durch Flucht (nach timeout)
- [ ] Combo-Fenster respektiert Dock-Duration

### Feel Tests
- [ ] Docking fühlt sich responsive an (< 100ms visual feedback)
- [ ] Gegner-Escape-Chance fühlt sich fair an
- [ ] Multi-Target Docking fühlt sich befriedigend an
- [ ] Keine Clipping-Probleme während Dock

### Edge Cases
- [ ] Was wenn Gegner stirbt während Dock? → Dock terminates
- [ ] Was wenn Gegner außer Bounds docked wird? → Automatisch breakup
- [ ] Was wenn Spieler docked und wird selbst attackiert? → Kann Dock brechen durch Knockback

---

## Performance Considerations

- **Pathfinding not needed**: Docking ist directionale Linie, nicht A*
- **No physics simulation**: Lineare Interpolation, nicht Godot Physics
- **Minimal Allocations**: Docking State ist einfach (bool, Node2D reference)

---

## Progression & Balancing

### Early Game
- Docking Distance: 400px (großzügig für Anfänger)
- Gegner können nicht escapen (einfach)
- Timeout: 2.0s (viel Zeit)

### Mid Game
- Docking Distance: 300px (normal)
- Gegner können escapen durch Angriff
- Timeout: 1.0s

### Late Game
- Docking Distance: 250px (strict)
- Gegner aggressive während docked
- Timeout: 0.8s (schneller)
- Gegner können durch Flucht auch escapen

---

## Narrative Integration

**Thematisch**: Docking ist **Gravitation**. Caprica's Musik-Energie **zieht** feindliche Gegner magnetisch an. Je stärker sie wird, desto weiter der Docking-Radius.

Das erklärt mechanisch, warum Docking Distance mit Progression wächst:
```gdscript
# In DockingSystem

var base_dock_distance: float = 300.0
var distance_multiplier: float = 1.0 + (player.level * 0.1)

func get_current_dock_distance() -> float:
    return base_dock_distance * distance_multiplier
```

---

## Fazit

Das Docking System ist die **Bridge zwischen großer Entfernung und Melee Combat**. Es:
- **Löst Distanz-Frustration**: Zu weit weg bedeutet nicht "Fehler", sondern "Dash erst"
- **Macht Combat Flow möglich**: Mehrere Gegner hintereinander ohne Stop
- **Gibt Gegner Agency**: Sie können escapen (nicht just stunned)
- **Belohnt Risiko/Reward**: Docking ist schnell aber gegner können kontern

Ein subtles, aber essentielles System für responsives, befriedigend Combat-Gefühl.
