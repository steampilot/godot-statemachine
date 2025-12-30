# SNAP-TO-BEAT SYSTEM

## Überblick

Das **Snap-to-Beat System** ist eine unsichtbare, aber gefühlte Mikro-Verzögerung, die Player-Attacks exakt mit dem Musik-Beat synchronisiert. Der Spieler drückt die Attack-Taste wann immer—das Spiel "snapped" die Aktion zum nächsten Beat, mit maximaler Latenz von 50ms.

**Kern-Idee**: Spieler merkt die Verzögerung nicht, **fühlt** aber die perfekte Synchronisation. Hit-Impact und Musik sind absolut in Sync—das erzeugt psychologisches Gefühl von Meisterschaft und "Rightness".

---

## Warum Snap-to-Beat wichtig ist

### Das Timing-Problem
Wenn Spieler manuell auf den Beat treffen müssen:
- Zu streng: Spieler fühlt sich unfair behandelt ("Ich war nah dran!")
- Zu großzügig: Keine Unterscheidung zwischen Good und Perfect Hit

**Snap-to-Beat** löst das: **Spieler sieht sofort "Ich hab den Hit", nicht "War das zu spät?"**

### Psychologischer Effekt
- **Gameplay fühlt sich "tight" an**—keine Latenz-Probleme
- **Musik + Impact sind Eins**—visuell und auditiv synchron
- **Spieler ist "in control"**—keine unsichtbaren Verzögerungen
- **Flow-State verstärkt**—Rhythmus fühlt sich natürlich an

### Best-Practice aus anderen Spielen
- **Crypt of the NecroDancer**: Snap-to-Beat ist Core Mechanic
- **Hades**: Hit-Register snappet zu Spiel-Rhythm
- **Sayonara Wild Hearts**: Alle Aktionen align mit Music

---

## Technische Implementierung

### Timing-Berechnung

```gdscript
# res/Globals/MUSIC_PLAYER.gd
# Central source of truth für Beats

extends Node

class_name MusicPlayer

var audio_stream_player: AudioStreamPlayer
var bpm: float = 120.0
var current_beat: float = 0.0

# Cached for performance
var beat_duration_ms: float = 0.0  # calculated from BPM

func _ready() -> void:
    audio_stream_player = $AudioStreamPlayer
    _update_beat_duration()

func _update_beat_duration() -> void:
    beat_duration_ms = (60.0 / bpm) * 1000.0  # ms per beat

func get_current_beat_precise() -> float:
    # Exact beat position (as float) based on playback position
    var playback_ms = audio_stream_player.get_playback_position() * 1000.0
    return playback_ms / beat_duration_ms

func get_current_beat_int() -> int:
    return int(get_current_beat_precise())

func get_time_to_next_beat_ms() -> float:
    # Time (in ms) until next beat
    var current_precise = get_current_beat_precise()
    var fractional_part = fmod(current_precise, 1.0)

    if fractional_part == 0.0:
        return 0.0  # Exactly on beat

    return (1.0 - fractional_part) * beat_duration_ms

func get_time_since_last_beat_ms() -> float:
    # Time (in ms) since last beat
    var current_precise = get_current_beat_precise()
    var fractional_part = fmod(current_precise, 1.0)
    return fractional_part * beat_duration_ms

func snap_to_nearest_beat(time_ms: float) -> float:
    # Given time, snap to nearest beat timestamp
    var beat_number = round(time_ms / beat_duration_ms)
    return beat_number * beat_duration_ms
```

### Attack Snap-to-Beat Logic

```gdscript
# res/entities/Player.gd (Combat Handler)

const SNAP_TO_BEAT_MAX_MS: float = 50.0  # Max invisible delay

func on_attack_intent(intent: Intent) -> void:
    var current_time_ms = Time.get_ticks_msec()

    # Calculate when to execute attack: snap to nearest beat
    var snapped_beat = MusicPlayer.snap_to_nearest_beat(current_time_ms)
    var snap_delay_ms = snapped_beat - current_time_ms

    # Clamp snap_delay to max (don't wait if too far from beat)
    if snap_delay_ms > SNAP_TO_BEAT_MAX_MS:
        snap_delay_ms = 0.0  # Just do it now

    # Schedule attack for snapped beat
    if snap_delay_ms > 0:
        # Wait until beat
        await get_tree().create_timer(snap_delay_ms / 1000.0).timeout

    # Execute attack at beat
    _execute_attack()

func _execute_attack() -> void:
    # This fires exactly on beat
    # Hit-Impact, Particles, Sound—all synchronized

    var target = get_closest_enemy()
    if target:
        var damage = 10
        var timing_bonus = _calculate_timing_bonus()

        target.take_damage(damage * timing_bonus)

        # Synchronize hit-impact with beat
        _trigger_hit_feedback()

        # Check for combo
        _update_combo()
```

### Combo mit Snap-to-Beat

```gdscript
# res/entities/Player.gd

var combo_count: int = 0
var last_hit_beat: int = -1
const COMBO_WINDOW_BEATS: int = 1  # Must hit within 1 beat

func _execute_attack() -> void:
    var current_beat = MusicPlayer.get_current_beat_int()

    # Check if this hit extends combo
    if current_beat <= last_hit_beat + COMBO_WINDOW_BEATS:
        combo_count += 1
    else:
        combo_count = 1  # Reset combo

    last_hit_beat = current_beat

    # Apply combo multiplier to damage
    var base_damage = 10
    var combo_multiplier = 1.0 + (combo_count - 1) * 0.2  # +20% per combo
    var final_damage = base_damage * combo_multiplier

    # ... apply damage

    # Visual feedback for combo
    _update_combo_display(combo_count)

func _on_missed_combo_window() -> void:
    # Too much time passed, combo broken
    combo_count = 0
```

### Snap-to-Beat mit Visual Feedback

```gdscript
# res/ui/SnapToBeadVis ualizer.gd
# Optional: Show player the snap happening

extends CanvasLayer

var is_snapping: bool = false
var snap_visual: ColorRect

func _ready() -> void:
    snap_visual = ColorRect.new()
    snap_visual.color = Color.WHITE
    snap_visual.modulate.a = 0.0
    add_child(snap_visual)

func on_snap_occurred(delay_ms: float) -> void:
    # Flash screen during snap
    if delay_ms > 5:  # Only visible for significant snaps
        is_snapping = true
        var tween = create_tween()
        tween.tween_property(snap_visual, "modulate:a", 0.3, delay_ms / 1000.0)
        tween.tween_property(snap_visual, "modulate:a", 0.0, 0.1)
        is_snapping = false
```

---

## Beat-Aligned Particle & Animation System

Alle visuellen Effekte müssen Beat-aligned sein, nicht smooth:

```gdscript
# res/effects/BeatAlignedParticles.gd
# Particles that emit in bursts aligned to beats

extends GPUParticles2D

@export var emit_every_n_beats: int = 1

func _ready() -> void:
    MusicPlayer.beat_occurred.connect(_on_beat)

func _on_beat(beat_number: int) -> void:
    if beat_number % emit_every_n_beats == 0:
        emit_burst()

func emit_burst() -> void:
    # Emit particles
    amount = 20
    emitting = true
    await get_tree().create_timer(0.05).timeout
    emitting = false
```

---

## Best Practices

### Timing Accuracy
- **Music Player muss exakt sein**: Use OS.get_ticks_msec() nicht game-clock (drift issues)
- **Sync Audio zu Input-System**: nicht umgekehrt
- **Regelmäßiges Beat-Syncing**: Alle 4-8 Takte neu-sync um Drift zu vermeiden

```gdscript
# Drift correction every 8 beats
var last_sync_beat: int = 0

func _on_beat(beat_number: int) -> void:
    if beat_number - last_sync_beat >= 8:
        _resync_audio()
        last_sync_beat = beat_number

func _resync_audio() -> void:
    # Kleine Latenz-Korrektionen einfügen um Audio/Input perfect in sync zu halten
    pass
```

### User Feedback
- **Subtil ist Besser**: Spieler sollte Snap nicht "spüren", nur Resultat
- **Keine Sichtbare Verzögerung**: Max 50ms ist unmerklich für Menschen
- **Hit-Feedback ist sofort**: Spieler sieht/hört Hit-Sound sofort (nicht verzögert)
- **Beat-Counter optional**: Zeige Beat-Nummer für Learning-Phase, verstecke später

### Performance
- **Cached Beat-Duration**: Nicht jeden Frame neu rechnen
- **Event-driven Beat-Ticks**: nicht continuous polling
- **Effiziente Timer**: Nutze Godot's `create_timer()` für Snap-Delays

---

## Integration mit anderen Systemen

### Mit Combat-System
Attack Snap-to-Beat ist transparent zum Combat-System:
```gdscript
# Combat System sieht: Player hat angegriffen
# Wann genau er angegriffen hat (Snap-Punkt) ist Details
# Combo-System registriert Hit-Beat, nicht Hit-Time
```

### Mit Rhythm Telegraph System
Enemy-Angriffe sind auch Beat-aligned:
```gdscript
# Enemy attacks on Beat 4
# Player sieht das (Visual telegraph)
# Player kann anticipate und snap-to-beat gegen
```

### Mit Dash/Movement
Dashes können auch optional snap-to-beat sein:
```gdscript
# Optional feature: Snap Dash-START zu nächstem Beat
# Macht Movement Rhythmus-basiert
# Nicht notwendig, aber würde fühlen sich "tight" an
```

---

## Testing & Validation

### Technical Tests
- [ ] Beat-Berechnung: Music Player ist ±5ms genau über 2 Minuten
- [ ] Snap-Delay: Immer ≤50ms (keine merkliche Latenz)
- [ ] Audio-Input Sync: Hit-Sound spielt exakt mit Impact
- [ ] Combo-Timing: Hits werden korrekt als Combo gezählt/gebrochen

### Feel Tests
- [ ] Spieler merkt Snap nicht (subjektiv—nicht zu betonen)
- [ ] Hit fühlt sich "tight" an
- [ ] Rhythm fühlt sich natürlich an (nicht rushed)
- [ ] Combo-Fenster fühlt sich fair an

### Edge Cases
- [ ] Was passiert wenn Music pausiert? → Snap funktioniert nicht (oder warte auf Resume)
- [ ] Was wenn BPM sich ändert? → Neuberechnung mit neuer BPM
- [ ] Was wenn Input kommt während Snap-Delay? → Erste Input zählt, Rest ignoriert
- [ ] High-Refresh-Rate Input (120Hz)? → Snap funktioniert noch (unabhängig von Display-Rate)

---

## Godot-spezifische Implementierungs-Tipps

### AudioStreamPlayer Latency
```gdscript
# AudioStreamPlayer hat built-in latency
# Kompensation mit get_playback_position() offset:

func get_audio_playback_time_ms() -> float:
    var raw_position = audio_stream_player.get_playback_position()
    var latency_compensation_ms = 20.0  # Adjust based on system
    return (raw_position * 1000.0) - latency_compensation_ms
```

### Timer Accuracy
```gdscript
# Nutze create_timer() für Sub-Frame Timing
# Aber wisse dass Godot 16ms Resolution hat (60 FPS)

await get_tree().create_timer(0.033).timeout  # Genau ~2 Frames
```

---

## Performance Optimizations

- **Beat-Ticks als Signal** statt continuous polling
- **Cached Calculations**: BeatDuration, nicht jeden Frame rechnen
- **Minimal State**: Combo-Count, Last-Beat nur was notwendig ist
- **No Allocations in Hot-Path**: On_attack_intent sollte keine neue Objects erstellen

---

## Fazit

Snap-to-Beat ist nicht sichtbar aber **fundamental zu Game-Feel**. Es macht Combat sich "tight" anfühlen und Rhythmus sich natürlich anfühlen. Es ist die unsichtbare Glue, die:
- Musik und Gameplay zusammenbindet
- Latenz versteckt aber nicht eliminiert
- Spieler Gefühl gibt "Ich bin perfekt in Sync"

Dies ist eines der wichtigsten Systeme um CapricaGame sich "polished" und "professional" anfühlen zu lassen.
