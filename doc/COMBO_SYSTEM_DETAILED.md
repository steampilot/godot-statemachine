# COMBO SYSTEM DETAILED

## Überblick

Das **Combo System** belohnt Spieler dafür, mehrere aufeinanderfolgende erfolgreiche Attacks zu landen, ohne eine Pause zu machen. Ein erfolgreicher Combo erzeugt:
- **Damage-Multiplikator**: +20% pro Combo-Hit
- **Knockback-Bonus**: Extra Kraft für Gegner-Dispersion
- **Visual/Audio Feedback**: Befriedigende Bestätigung
- **Rhythmische Dimension**: Beat-Timing verstärkt Combo-Länge

Combos sind **nicht erzwungen** (Spieler kann auch ohne Sie spielen), aber **stark belohnend** (Höhere Risiko = Höhere Belohnung).

---

## Combo-Fenster Mechanic

### Zeit-basiertes Fenster

Ein Combo bleibt aktiv solange der Spieler innerhalb eines **Zeit-Fensters** einen neuen Hit landet:

```gdscript
# res/combat/combo_system.gd

extends Node
class_name ComboSystem

class ComboState:
    var count: int = 0
    var last_hit_timestamp: float = 0.0
    var last_hit_beat: int = 0
    var is_active: bool = false

var combo_state: ComboState = ComboState.new()
var combo_window_seconds: float = 0.8  # 800ms window
var combo_window_beats: int = 1  # Alternative: Beat-based window

signal combo_changed(new_count: int, max_combo: int)
signal combo_broken()
signal perfect_combo()  # All hits were rhythm-perfect

func register_hit() -> void:
    var current_time = Time.get_ticks_msec() / 1000.0
    var current_beat = MusicPlayer.get_current_beat_int()

    # Check if within combo window
    var time_since_last_hit = current_time - combo_state.last_hit_timestamp
    var beats_since_last_hit = current_beat - combo_state.last_hit_beat

    if combo_state.count == 0:
        # First hit, start new combo
        combo_state.count = 1
        combo_state.is_active = true
    elif time_since_last_hit <= combo_window_seconds:
        # Within window, continue combo
        combo_state.count += 1
    else:
        # Outside window, start new combo
        combo_broken.emit()
        combo_state.count = 1

    # Update timestamps
    combo_state.last_hit_timestamp = current_time
    combo_state.last_hit_beat = current_beat

    # Emit signal for UI update
    combo_changed.emit(combo_state.count, combo_state.count)

func get_combo_multiplier() -> float:
    # Base: 1.0x (no multiplier)
    # +20% per combo hit: 1.0, 1.2, 1.4, 1.6, etc.
    return 1.0 + (combo_state.count - 1) * 0.2

func reset_combo() -> void:
    combo_state.count = 0
    combo_state.is_active = false
    combo_broken.emit()
```

### Beat-basiertes Fenster (Rhythmisch)

Für präzisere Rhythm-Kontrolle, nutzen wir auch **Beat-Fenster**:

```gdscript
# Alternative: Beat-based combo window
# Combo bleibt aktiv wenn Hits auf aufeinanderfolgenden Beats landen

func register_hit_beat_based() -> void:
    var current_beat = MusicPlayer.get_current_beat_int()

    if combo_state.count == 0:
        combo_state.count = 1
    elif current_beat <= combo_state.last_hit_beat + 1:
        # Hit landed within 1 beat = Combo continues
        combo_state.count += 1
    else:
        # Gap > 1 beat = Combo broken
        combo_broken.emit()
        combo_state.count = 1

    combo_state.last_hit_beat = current_beat
    combo_changed.emit(combo_state.count, combo_state.count)
```

**Hybrid-Approach** (empfohlen):
- **Anfänger-Level**: 1.0 Sekunde Fenster (großzügig)
- **Mid-Level**: 0.8 Sekunden + Beat-Timing Bonus
- **Expert-Level**: Beat-basiert (nur ein Beat Fenster)

---

## Damage-Multiplikator System

### Berechnung

```gdscript
# res/combat/combat_engine.gd

func calculate_final_damage(base_damage: int) -> int:
    var combo_multiplier = combo_system.get_combo_multiplier()
    var rhythm_bonus = _calculate_rhythm_bonus()
    var attack_type_modifier = _get_attack_type_modifier()

    var final_damage = base_damage * combo_multiplier * rhythm_bonus * attack_type_modifier
    return int(final_damage)

func _calculate_rhythm_bonus() -> float:
    var time_to_beat = MusicPlayer.get_time_to_next_beat_ms()

    if abs(time_to_beat) <= 50:  # Perfect
        return 1.5
    elif abs(time_to_beat) <= 150:  # Good
        return 1.2
    else:  # Normal
        return 1.0

func _get_attack_type_modifier() -> float:
    # Punch: 1.0x, Kick: 1.2x, Finisher: 1.5x
    match combo_system.get_combo_count():
        0: return 1.0  # Punch
        1: return 1.2  # Kick
        _: return 1.5  # Finisher
```

### Beispiel-Damage-Berechnung

```
Base Damage: 10

Combo 1 (Punch):
  - Combo Multiplier: 1.0
  - Rhythm: Good (1.2x)
  - Attack Modifier: 1.0x
  - Final: 10 * 1.0 * 1.2 * 1.0 = 12 damage

Combo 2 (Kick):
  - Combo Multiplier: 1.2 (20% bonus)
  - Rhythm: Perfect (1.5x)
  - Attack Modifier: 1.2x
  - Final: 10 * 1.2 * 1.5 * 1.2 = 21.6 damage

Combo 3 (Finisher):
  - Combo Multiplier: 1.4 (40% bonus)
  - Rhythm: Good (1.2x)
  - Attack Modifier: 1.5x
  - Final: 10 * 1.4 * 1.2 * 1.5 = 25.2 damage
```

---

## Knockback Integration

Combos verstärken auch **Knockback**:

```gdscript
# res/combat/combat_engine.gd

func apply_combo_knockback(target: Node2D, base_knockback: float) -> void:
    var combo_count = combo_system.get_combo_count()

    # Knockback scales with combo
    var knockback_multiplier = 1.0 + (combo_count - 1) * 0.3
    var final_knockback = base_knockback * knockback_multiplier

    var knockback_direction = (target.global_position - player.global_position).normalized()
    target.apply_knockback(knockback_direction * final_knockback)

# Attack-spezifische Knockback-Werte
var knockback_table: Dictionary = {
    "punch": 100.0,    # Punch: 100-250 px/s
    "kick": 250.0,     # Kick: 250-625 px/s
    "finisher": 400.0  # Finisher: 400-1000 px/s
}
```

---

## Visuelle & Audio-Feedback

### Combo Counter Display

```gdscript
# res/ui/ComboDisplay.gd

extends CanvasLayer
class_name ComboDisplay

@onready var combo_label: Label = $ComboLabel
@onready var combo_number: Label = $ComboNumber
@onready var combo_meter: ProgressBar = $ComboMeter

var combo_system: ComboSystem

func _ready() -> void:
    combo_system = get_node("/root/Main/ComboSystem")
    combo_system.combo_changed.connect(_on_combo_changed)
    combo_system.combo_broken.connect(_on_combo_broken)

func _on_combo_changed(current_combo: int, max_combo: int) -> void:
    combo_number.text = "%dx" % current_combo

    # Update combo meter (visual representation of combo window countdown)
    var combo_percentage = combo_system.get_combo_window_progress()
    combo_meter.value = combo_percentage

    # Pulse animation on new combo hit
    if current_combo > 1:
        _play_combo_pulse(current_combo)

func _play_combo_pulse(combo_count: int) -> void:
    var tween = create_tween()

    # Scale up
    tween.tween_property(combo_number, "scale", Vector2(1.3, 1.3), 0.05)
    tween.tween_property(combo_number, "scale", Vector2(1.0, 1.0), 0.05)

    # Color flash based on combo intensity
    var combo_color = Color.YELLOW if combo_count < 3 else Color.RED
    tween.tween_property(combo_label, "modulate", combo_color, 0.1)
    tween.tween_property(combo_label, "modulate", Color.WHITE, 0.1)

func _on_combo_broken() -> void:
    combo_number.text = ""
    combo_meter.value = 0

    # Sad animation
    var tween = create_tween()
    tween.tween_property(combo_label, "modulate", Color.RED, 0.2)
    tween.tween_property(combo_label, "modulate", Color.WHITE, 0.2)

func get_combo_window_progress() -> float:
    # Returns 0.0-1.0 based on time remaining in combo window
    var time_since_hit = Time.get_ticks_msec() / 1000.0 - combo_system.last_hit_timestamp
    var remaining = max(0.0, combo_system.combo_window_seconds - time_since_hit)
    return remaining / combo_system.combo_window_seconds
```

### Audio Feedback

```gdscript
# In ComboSystem._on_combo_hit()

func _trigger_combo_feedback(combo_count: int) -> void:
    # Hit sound varies by combo milestone
    match combo_count:
        1:
            Audio.play_sfx("hit_combo_1")
        2:
            Audio.play_sfx("hit_combo_2")
        3:
            Audio.play_sfx("hit_combo_3")
        _:
            if combo_count % 2 == 0:
                Audio.play_sfx("hit_combo_milestone")

    # Pitch shift increases with combo (optional)
    # var pitch_shift = 1.0 + (combo_count - 1) * 0.1
    # Audio.set_pitch_for_sfx("hit_combo", pitch_shift)
```

---

## Perfect Combo Mechanic

Ein **Perfect Combo** wird erreicht, wenn alle Hits im Combo auf Rhythm-Perfect landen (±50ms):

```gdscript
# In ComboSystem

var perfect_combo_hits: int = 0

func register_hit(is_rhythm_perfect: bool) -> void:
    if combo_state.count == 0:
        perfect_combo_hits = 0

    if is_rhythm_perfect:
        perfect_combo_hits += 1
    else:
        perfect_combo_hits = 0  # Reset if not perfect

    # ... register combo as normal

    # Check if perfect combo achieved
    if perfect_combo_hits >= 3:  # 3 perfect hits in a row
        trigger_perfect_combo_event()

func trigger_perfect_combo_event() -> void:
    perfect_combo.emit()

    # Extra damage/knockback bonus
    var next_damage_bonus = 1.5  # 50% extra for next hit

    # Screen effect
    get_viewport().get_node("Camera2D").shake(0.2, 1.0)

    # Audio: Triumphant sound
    Audio.play_sfx("perfect_combo_achieved")

    # Particles: Explosion effect
    var vfx = preload("res://Scenes/Effects/PerfectComboFlash.tscn").instantiate()
    add_child(vfx)
```

---

## Progression durch Combo-Komplexität

### Early Game
- **Combo Window**: 1.0 Sekunden (großzügig)
- **Combo Multiplier**: Linear (+20% pro Hit)
- **Max Visible Combo**: 5 (überschaubar)

### Mid Game
- **Combo Window**: 0.8 Sekunden
- **Combo Multiplier**: +25% pro Hit (steiler)
- **Perfect Combo Feature**: Unlock "Perfect Combo" (3x Perfect Hits)
- **Gegner-Complexity**: Gegner können docking breakup um combo zu zerbrechen

### Late Game/Boss
- **Combo Window**: Beat-basiert (1 Beat window)
- **Combo Multiplier**: +30% pro Hit (sehr belohnend)
- **Perfect Combo**: Notwendig für optimal damage
- **Enemy Pattern**: Gegner attacks on Beats um Combos zu unterbrechen

---

## Integration mit anderen Systemen

### Mit Docking System
Wenn Spieler mehrere Gegner hintereinander docked, können Combos über multiple Gegner hinweg weitergehen:

```gdscript
# In combat_engine

func on_target_changed(new_target: Node2D) -> void:
    # Don't reset combo when switching targets during dock
    if docking_system.is_docking:
        combo_system.combo_window_seconds = 1.5  # Extended window
    else:
        combo_system.combo_window_seconds = 0.8  # Normal window
```

### Mit Rhythm System
Beat-Timing gibt Extra-Bonuse:
- Perfect Hit (±50ms): 1.5x Damage
- Good Hit (±150ms): 1.2x Damage
- Normal Hit: 1.0x Damage

Plus Combo-Multiplier stacking.

### Mit Knockback
Höhere Combos = Stärkere Knockback = Gegner fliegen weiter = Mehr Space für nächsten Combo Hit

---

## Edge Cases & Balancing

### Was bricht Combos?

```gdscript
# Combo wird unterbrochen durch:
# 1. Timeout (outside combo window)
# 2. Player takes damage
# 3. Gegner stirbt (kein neuer Target)
# 4. Docking breakup
# 5. Spieler selbst disabled (Freeze, Stun)

func on_player_damaged() -> void:
    combo_system.reset_combo()

func on_enemy_died() -> void:
    # If no other enemies nearby, break combo
    var nearby_enemies = find_enemies_in_radius(500)
    if nearby_enemies.size() == 0:
        combo_system.reset_combo()
```

### Comeback Mechanic
Wenn Spieler lange kein Hit landet, geben wir ihnen eine Gnade-Periode:

```gdscript
# If player hasn't hit in 2 seconds, slightly extend combo window for next hit
var COMBO_GRACE_PERIOD: float = 2.0

func _process(delta: float) -> void:
    var time_since_last_hit = Time.get_ticks_msec() / 1000.0 - combo_system.last_hit_timestamp

    if time_since_last_hit > COMBO_GRACE_PERIOD and combo_system.combo_state.count > 0:
        # Slightly extend window (1.5s instead of 0.8s) for comebacks
        combo_system.combo_window_seconds = 1.2
    else:
        combo_system.combo_window_seconds = 0.8
```

---

## Testing & Validation

### Mechanical Tests
- [ ] Combo-Counter increments korrekt
- [ ] Combo-Window Timeout funktioniert
- [ ] Damage-Multiplikator wird korrekt angewendet
- [ ] Knockback-Multiplikator funktioniert
- [ ] Perfect Combo triggert nur bei 3x Perfect Hits

### Feel Tests
- [ ] Combo-System fühlt sich befriedigend an
- [ ] Fenster ist nicht zu streng/großzügig
- [ ] Feedback ist klar (visuell, audio, haptic)
- [ ] Multi-Target Combos fühlen sich flüssig an

### Balance Tests
- [ ] Ein 3-Hit Combo macht sichtbare Differenz (min 50% extra damage)
- [ ] Ein 5-Hit Combo ist schwer zu erreichen aber erreichbar
- [ ] Perfect Combo Bonus ist motivierend
- [ ] Gegner können Combos unterbrechen (nicht OP)

---

## Narrative Integration

Thematisch: **Combo = Musik-Harmonie**. Jeder erfolgreiche Hit synchronisiert Caprica mit der Musik. Je mehr Hits, desto mehr Harmonie, desto stärker sie wird.

```
Combo 1: "Caprica trifft Takt"
Combo 2: "Sie harmonisiert mit der Musik"
Combo 3: "Ihre Energie flutet"
Combo 5: "Sie wird eins mit der Musik"
Perfect Combo: "Absolut Perfektion!"
```

---

## Fazit

Das Combo System ist die **Belohnungs-Struktur für skillbasiertes Gameplay**. Es:
- **Belohnt Geschicklichkeit**: Höhere Combos = Höherer Skill
- **Schafft Progression**: Spieler will längere Combos
- **Integriert mit Rhythm**: Beat-Timing ist nicht optional, es ist belohnend
- **Schafft Einbindung**: Spieler ist in "Zone" bei langen Combos

Ein wesentliches System für tiefgehende, befriedigende Combat-Erfahrung.
