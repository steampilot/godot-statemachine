# INTENT-BASED COMBAT DETAILED

## Überblick

**Intent-Based Combat** entkoppelt Player-Input von Spiel-Logik. Statt direkter "Drücke X = Spiele Animation", wird Input zu abstrakten **Intent-Objekten** konvertiert, die verschiedene Quellen haben können: Spieler-Input, KI-Gegner, Netzwerk, oder Replay-System.

Dies schafft ein flexibles, wartbares und erweiterungsfähiges Combat-System, bei dem die gleiche Kampf-Logik für Player, Gegner und zukünftige Features verwendet werden kann.

---

## Kern-Architektur

### Intent Definition

```gdscript
# res/player/intent.gd

extends Resource
class_name Intent

enum Type {
    MOVE,           # direction + speed
    JUMP,
    DASH,
    ATTACK,         # base combat action
    INTERACT,
    CANCEL
}

var type: Type
var data: Dictionary  # Flexible data container

func _init(p_type: Type = Type.MOVE, p_data: Dictionary = {}) -> void:
    type = p_type
    data = p_data

# Convenience constructors
static func move(direction: Vector2, speed: float = 1.0) -> Intent:
    var intent = Intent.new(Type.MOVE)
    intent.data["direction"] = direction
    intent.data["speed"] = speed
    return intent

static func attack(target_position: Vector2 = Vector2.ZERO) -> Intent:
    var intent = Intent.new(Type.ATTACK)
    intent.data["target_pos"] = target_position
    intent.data["timestamp"] = Time.get_ticks_msec()
    return intent

static func dash(direction: Vector2) -> Intent:
    var intent = Intent.new(Type.DASH)
    intent.data["direction"] = direction
    return intent
```

### Intent Emitter (Input → Intent)

```gdscript
# res/player/intent_emitter.gd
# EINZIGE Stelle, die Player-Input liest

extends Node
class_name IntentEmitter

signal intent_emitted(intent: Intent)

func _input(event: InputEvent) -> void:
    # Block raw input from reaching rest of game
    get_tree().set_input_as_handled()

    if event.is_action_pressed("move_right"):
        emit_intent(Intent.move(Vector2.RIGHT))
    elif event.is_action_pressed("move_left"):
        emit_intent(Intent.move(Vector2.LEFT))
    elif event.is_action_pressed("jump"):
        emit_intent(Intent.new(Intent.Type.JUMP))
    elif event.is_action_pressed("dash"):
        emit_intent(Intent.new(Intent.Type.DASH))
    elif event.is_action_pressed("attack"):
        # Attack intent includes closest enemy as target
        var target_pos = _find_closest_enemy_position()
        emit_intent(Intent.attack(target_pos))

func emit_intent(intent: Intent) -> void:
    intent_emitted.emit(intent)

func _find_closest_enemy_position() -> Vector2:
    # Logic to find attack target
    var player = get_parent()
    var closest_enemy = null
    var closest_distance = float('inf')

    for enemy in get_tree().get_nodes_in_group("enemies"):
        var distance = player.global_position.distance_to(enemy.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest_enemy = enemy

    return closest_enemy.global_position if closest_enemy else player.global_position
```

### Combat Engine (Intent Handler)

```gdscript
# res/combat/combat_engine.gd
# Zentrale Logik für alle Angriffe

extends Node
class_name CombatEngine

class AttackProperties:
    var damage: int
    var knockback: Vector2
    var combo_window_beats: int
    var animation: String

    func _init(p_damage: int, p_knockback: Vector2, p_anim: String) -> void:
        damage = p_damage
        knockback = p_knockback
        animation = p_anim
        combo_window_beats = 1

# Attack library
var attacks: Dictionary = {}

func _ready() -> void:
    # Define all attack types
    attacks["punch"] = AttackProperties.new(10, Vector2(100, 0), "punch")
    attacks["kick"] = AttackProperties.new(15, Vector2(250, 0), "kick")
    attacks["finisher"] = AttackProperties.new(30, Vector2(400, 0), "finisher")

func handle_attack_intent(intent: Intent, attacker: Node2D) -> void:
    var target_pos = intent.data.get("target_pos", attacker.global_position)
    var distance = attacker.global_position.distance_to(target_pos)

    # Determine attack type based on distance or combo state
    var attack_type = _determine_attack_type(distance, attacker)
    var attack_props = attacks.get(attack_type)

    if not attack_props:
        return

    # Check for rhythm bonus
    var rhythm_bonus = _calculate_rhythm_bonus()
    var final_damage = attack_props.damage * rhythm_bonus

    # Apply damage to target
    var target = _find_target_at_position(target_pos)
    if target:
        target.take_damage(final_damage)
        target.apply_knockback(attack_props.knockback)

        # Trigger docking system if far away
        if distance > 300:
            _initiate_docking(attacker, target)

        # Feedback
        _trigger_hit_feedback(attacker, target, attack_type)

func _determine_attack_type(distance: float, attacker: Node) -> String:
    # Check combo state
    if attacker.combo_count == 0:
        return "punch"
    elif attacker.combo_count == 1:
        return "kick"
    else:
        return "finisher"

func _calculate_rhythm_bonus() -> float:
    var time_to_beat = MusicPlayer.get_time_to_next_beat_ms()
    if abs(time_to_beat) <= 50:  # Perfect
        return 1.5
    elif abs(time_to_beat) <= 150:  # Good
        return 1.2
    else:  # Normal
        return 1.0

func _find_target_at_position(pos: Vector2) -> Node:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.global_position.distance_to(pos) < 50:  # Detection radius
            return enemy
    return null

func _trigger_hit_feedback(attacker: Node2D, target: Node2D, attack_type: String) -> void:
    # Screen shake
    get_viewport().get_node("Camera2D").shake(0.1, 0.5)

    # Sound
    Audio.play_sfx("hit_%s" % attack_type)

    # Particles
    var hit_pos = target.global_position
    _spawn_hit_particles(hit_pos, attack_type)

    # Combo update
    attacker.combo_count += 1
```

### Player Combat Receiver

```gdscript
# res/entities/Player.gd (Combat Handler)

extends CharacterBody2D

var combat_engine: CombatEngine
var combo_count: int = 0
var last_hit_beat: int = -1

signal combo_changed(new_combo: int)

func _ready() -> void:
    combat_engine = CombatEngine.new()
    add_child(combat_engine)

    # Listen to intent emitter
    var intent_emitter = $IntentEmitter
    intent_emitter.intent_emitted.connect(_on_intent)

func _on_intent(intent: Intent) -> void:
    match intent.type:
        Intent.Type.MOVE:
            _handle_move_intent(intent)
        Intent.Type.JUMP:
            _handle_jump_intent(intent)
        Intent.Type.DASH:
            _handle_dash_intent(intent)
        Intent.Type.ATTACK:
            _handle_attack_intent(intent)

func _handle_attack_intent(intent: Intent) -> void:
    # Let combat engine handle the details
    combat_engine.handle_attack_intent(intent, self)

    # Update last hit beat for combo window
    last_hit_beat = MusicPlayer.get_current_beat_int()
    combo_changed.emit(combo_count)

func _handle_move_intent(intent: Intent) -> void:
    var direction = intent.data.get("direction", Vector2.ZERO)
    velocity.x = direction.x * 200  # speed

func _handle_jump_intent(intent: Intent) -> void:
    if is_on_floor():
        velocity.y = -400  # jump force

func _handle_dash_intent(intent: Intent) -> void:
    var direction = intent.data.get("direction", Vector2.RIGHT)
    # Trigger dash logic
    pass
```

---

## Advanced Combat Features

### Auto-Dash bei Distance

Wenn Spieler Angriff-Intent ausgibt, aber > 300px entfernt:

```gdscript
# In CombatEngine.handle_attack_intent()

func _initiate_docking(attacker: Node2D, target: Node2D) -> void:
    # Auto-activate dash towards target
    var distance = attacker.global_position.distance_to(target.global_position)
    var direction = (target.global_position - attacker.global_position).normalized()

    # Create auto-dash intent
    var dash_intent = Intent.dash(direction)
    attacker._handle_dash_intent(dash_intent)

    # Queue attack for after dash completes
    var dash_duration = distance / 500.0  # 500 px/s dash speed
    await get_tree().create_timer(dash_duration).timeout

    # Now execute actual attack
    handle_attack_intent(Intent.attack(target.global_position), attacker)
```

### Animation Control (Rücken → Hand)

Gitarre-spezifische Attack-Animation:

```gdscript
# res/attacks/GuitarAttack.gd
# Spezialisiert für Gitarren-Waffe

extends Node

func trigger_guitar_attack(player: Node2D, target: Node2D) -> void:
    var player_pos = player.global_position
    var target_pos = target.global_position

    # Guitar moves from back to hand
    var guitar = player.get_node("Guitar")

    var tween = create_tween()
    tween.set_parallel(true)

    # Rotate guitar to strike position
    tween.tween_property(guitar, "rotation", PI/4, 0.2)

    # Move guitar forward (hand position)
    tween.tween_property(guitar, "position", Vector2(50, 0), 0.2)

    # Player sprite turns towards target
    tween.tween_property(player, "rotation",
        (target_pos - player_pos).angle(), 0.1)

    # Sound effect on impact frame
    await tween.finished
    Audio.play_sfx("guitar_hit")

    # Return guitar to back
    var return_tween = create_tween()
    return_tween.tween_property(guitar, "position", Vector2(-30, 0), 0.15)
    return_tween.tween_property(guitar, "rotation", 0, 0.15)
```

---

## Combo-System Integration

### Combo-Fenster & Beat-Timing

```gdscript
# In Player.gd

const COMBO_WINDOW_BEATS: int = 1  # Must hit within 1 beat

func _handle_attack_intent(intent: Intent) -> void:
    var current_beat = MusicPlayer.get_current_beat_int()

    # Check if combo should continue
    if current_beat <= last_hit_beat + COMBO_WINDOW_BEATS:
        # Combo continues
        combo_count += 1
    else:
        # Combo broken
        combo_count = 1

    # Apply rhythm bonus on top of combo
    var rhythm_bonus = combat_engine._calculate_rhythm_bonus()
    var combo_multiplier = 1.0 + (combo_count - 1) * 0.2  # +20% per hit
    var final_damage_multiplier = rhythm_bonus * combo_multiplier

    # Pass to combat engine
    intent.data["damage_multiplier"] = final_damage_multiplier
    combat_engine.handle_attack_intent(intent, self)
```

### Combo Display

```gdscript
# res/ui/ComboDisplay.gd

extends CanvasLayer

@onready var combo_label: Label = $ComboLabel
@onready var combo_number: Label = $ComboNumber

func _ready() -> void:
    var player = get_node("../../Player")
    player.combo_changed.connect(_on_combo_changed)

func _on_combo_changed(new_combo: int) -> void:
    combo_number.text = str(new_combo) + "x"

    # Pulse animation on new combo hit
    if new_combo > 1:
        var tween = create_tween()
        tween.tween_property(combo_number, "scale", Vector2(1.3, 1.3), 0.1)
        tween.tween_property(combo_number, "scale", Vector2(1.0, 1.0), 0.1)
```

---

## Enemy Combat (AI Intents)

Gegner verwenden gleiches System, aber generieren Intents basierend auf AI:

```gdscript
# res/entities/Enemy.gd (Combat Handler)

extends CharacterBody2D

class_name Enemy

var behavior_tree: BehaviorTree
var intent_system: Node

func _ready() -> void:
    behavior_tree = BehaviorTree.new()
    _setup_behavior_tree()

func _setup_behavior_tree() -> void:
    # Example: Simple attack pattern on beat
    behavior_tree.root = BehaviorTree.Sequence([
        BehaviorTree.WaitForBeat(4),  # Wait until beat 4
        BehaviorTree.GenerateIntent(Intent.attack(get_target_position())),
        BehaviorTree.AnimationPlay("attack"),
        BehaviorTree.WaitForAnimation(),
    ])

func _process(delta: float) -> void:
    if behavior_tree:
        var status = behavior_tree.tick()

        # If behavior tree generated intent, handle it
        if status == BehaviorTree.Status.SUCCESS:
            var intent = behavior_tree.get_generated_intent()
            _on_intent(intent)

func _on_intent(intent: Intent) -> void:
    match intent.type:
        Intent.Type.ATTACK:
            _handle_attack_intent(intent)

func _handle_attack_intent(intent: Intent) -> void:
    var target_pos = intent.data.get("target_pos")
    var player = get_node("../../Player")

    # Attack player
    player.take_damage(10)

    # Apply knockback
    var direction = (player.global_position - global_position).normalized()
    player.apply_knockback(direction * 150)
```

---

## Best Practices

### Intent Design
- **Intents sind stateless**: Enthalten nur Daten, keine Logik
- **Daten-basiert nicht Enum-basiert**: Nutze data Dictionary für Flexibilität
- **Immer timestamp enthalten**: Für Replay/Netcode

### Handler Design
- **Eine Funktion pro Intent-Type**: `_handle_attack_intent()`, `_handle_move_intent()`
- **Konsistente Signale**: Handlers emittieren Signals für State-Changes
- **Keine Cross-Contamination**: Combat-Handler kennt nichts von Movement

### Performance
- **Intents sind leicht**: Schnelle Erstellung und Garbage Collection
- **No allocations in hot path**: Cachen Sie Attack-Properties
- **Signal-based statt continuous polling**

---

## Integration mit anderen Systemen

### Mit Docking System
Auto-Dash triggert beim Attack-Intent wenn zu weit weg.

### Mit Snap-to-Beat
Attack-Intent wird zum nächsten Beat snapped (max 50ms Delay).

### Mit Combo System
Combo-Count wird aktualisiert auf jedem erfolgreichen Attack-Intent.

### Mit Rhythmus-Philosophie
Intent ist abstrakt—ob Spieler "manuell" oder "per Rhythm" trifft, ist egal. Intent wird gleich behandelt.

---

## Testing & Validation

### Unit Tests
- [ ] Intent Erstellung funktioniert korrekt
- [ ] Combat Engine berechnet Damage korrekt (mit Boni)
- [ ] Combo-Fenster funktioniert zeitbasiert
- [ ] Knockback wird angewendet

### Integration Tests
- [ ] Player-Input → Intent → Combat Engine → Enemy Damage
- [ ] Enemy AI → Intent → Player Damage
- [ ] Combo-Fenster respektiert Beat-Boundaries
- [ ] Auto-Dash trigert bei richtiger Distance

### Gameplay Feel
- [ ] Attacks fühlen sich responsive an (no lag)
- [ ] Combo fühlt sich befriedigend an
- [ ] Feedback ist clear (visuell, audio, haptic)
- [ ] Rhythm-Bonus wird gefühlt

---

## Fazit

Intent-Based Combat schafft ein flexibles, wartbares System, bei dem:
- **Input ist abstrahiert** von Logik
- **AI, Player, Netcode verwenden gleiche Logik**
- **Replay und Undo sind einfach** (nur Intents speichern/abspielen)
- **Testing ist leicht** (Intents als Unit-Test Input)
- **Zukünftige Features sind einfach** (neue Intent-Types hinzufügen)

Dies ist das Fundament für ein professionelles Combat-System.
