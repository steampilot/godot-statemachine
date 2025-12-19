# Motor: Motion & Animation System

## 🎬 Überblick

**Motor = Motion Engine für Animation & Sound**

Der Motor beobachtet `StateFlags` und steuert das gesamte Animations-System:
- AnimationPlayer2D (zentrale Steuerung)
- AnimatedSprite2D (Visuals)
- Sound-Effekte (synchron mit Animationen)
- Particle-Effekte
- Andere Attribute

```
StateFlags (Wahrheit)
    ↓
Motor.update_animation()
    ↓
Wähle passende Animation
    ↓
AnimationPlayer2D.play()
    ↓
AnimatedSprite2D + Sounds + Effekte
```

## 🏗️ Architektur

### Drei-Schichten-System

```
Layer 2: Engine (Physik)
  └─ velocity berechnen
  └─ move_and_slide()
  └─ StateFlags.grounded aktualisieren

Layer 3: StateFlags (Wahrheit)
  └─ controlled (Puppeteered?)
  └─ grounded (Am Boden?)
  └─ alive (Noch am Leben?)

Layer 4: Motor (Animation)
  └─ Beobachtet StateFlags
  └─ Steuert AnimationPlayer2D
  └─ Triggert AnimatedSprite2D
  └─ Spielt Sounds ab
```

## 🎞️ Animation-Auswahl

Motor wählt automatisch die passende Animation:

```gdscript
func _get_target_animation() -> String:
    # Controlled (auf Chair, im Auto, etc.)
    if state.controlled:
        return "sit"

    # Nicht am Leben
    if not state.alive:
        return "dead"

    # In der Luft
    if not state.grounded:
        if body.velocity.y > 0:
            return "fall"
        else:
            return "jump"

    # Am Boden - Bewegung oder Idle?
    if abs(body.velocity.x) > 0.1:
        return "run"

    return "idle"
```

## 🎨 AnimationPlayer2D Setup

Deine Animations sollten so heißen:
```
idle    → Stillstehen
run     → Laufen
jump    → In der Luft (aufsteigend)
fall    → Fallen (absteigend)
sit     → Kontrolliert (Stuhl, Auto, etc.)
dead    → Tot
```

Jede Animation kann:
- AnimatedSprite2D triggern
- Sound-Effekte abspielen
- Partikel spawnen
- Andere Attribute ändern

Beispiel in AnimationPlayer2D:
```
Animation "jump":
  Frame: 0 → sprite.play("jump_start")
  Frame: 3 → play_sound("jump_sfx")
  Frame: 6 → particles.emitting = true

Animation "run":
  Frame: 0-2 Cycle:
    sprite.play("run_loop")
    Frame: 1 → play_sound("footstep_left")
    Frame: 3 → play_sound("footstep_right")
```

## 🔊 Sound-Integration

Motor kann Sounds über AnimationPlayer2D-Callbacks triggern:

```gdscript
func _on_animation_finished(anim_name: String):
    match anim_name:
        "jump":
            play_sound("jump")
        "land":
            play_sound("land")
        "drink":
            play_sound("drink")
```

Oder direkt in AnimationPlayer-Tracks:
```
Animation "jump":
  Method Track → _on_jump_sound() at Frame 0
```

## 🎮 Sprite-Direction

Motor handelt automatisch die Sprite-Richtung:

```gdscript
func update_sprite_direction():
    """Flipped Sprite basierend auf Bewegungsrichtung"""
    if abs(body.velocity.x) > 0.1:
        animated_sprite.flip_h = body.velocity.x < 0
```

Links → flip_h = true
Rechts → flip_h = false

## 📊 Motor vs. Engine

| Aspekt | Engine | Motor |
|--------|--------|-------|
| **Input** | Intents | StateFlags |
| **Output** | velocity, move_and_slide() | AnimationPlayer.play() |
| **Physik** | ✅ JA | ❌ NEIN |
| **Animation** | ❌ NEIN | ✅ JA |
| **Update** | _physics_process() | _physics_process() |
| **Beobachter** | ❌ | ✅ (liest nur, schreibt nicht zu StateFlags) |

## 🎯 Praktisches Beispiel: Player im Chair

```
1. Player sitzt auf Chair
   chair.capture(player)
   state.controlled = true

2. Motor beobachtet StateFlags
   state.controlled == true

3. Motor wählt Animation
   target_anim = "sit"

4. Motor triggert
   animation_player.play("sit")

5. AnimationPlayer2D steuert alles
   └─ AnimatedSprite2D zeigt Sit-Animation
   └─ Sound: "sit_down" bei Frame 5
   └─ Particles: Dust-Effekt
   └─ Attribute: player.modulate.opacity = 0.8
```

## 🚀 Erweiterungen

### Custom Animations vom Puppeteer

```gdscript
# Chair.gd
func on_capture(player: Player):
    player.motor.trigger_animation("sit_chair_specific")
```

### Blend-Effekte zwischen Animationen

```gdscript
# Motor.gd
func _transition_to(anim_name: String):
    animation_player.play(anim_name)
    # Optional: Crossfade
    # animation_player.play(anim_name, -1, 1.0)  # 1.0 = speed
```

### Layer-Animation (für komplexe Posen)

AnimationPlayer2D unterstützt mehrere Tracks:
```
Body Track → idle/run/jump
Arm Track → holding_ball/empty
Head Track → looking_up/down/forward
```

Alle synchron gesteuert!

## 📝 Checklist für neue Animationen

- [ ] Animation in AnimationPlayer2D definiert
- [ ] Name folgt Convention (idle, run, jump, fall, sit, dead)
- [ ] AnimatedSprite2D wird getriggert
- [ ] Sound-Effekte eingebunden (wenn nötig)
- [ ] Sprite-Flip funktioniert für Links/Rechts
- [ ] Motor hat Regel für diese Animation

---

**Siehe auch:**
- [motor.gd](src/player/motor.gd) – Implementierung
- [ARCHITECTURE.md](ARCHITECTURE.md) – Design-Überblick
