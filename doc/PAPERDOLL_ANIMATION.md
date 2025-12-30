# Paperdoll Animation Architecture

*Bone-Basierte Animation für Flexibilität, Reusability & Einfachheit*

---

## Warum Paperdoll Animation?

### Das Problem mit klassischem Animated Sprite Sheet

❌ **Sprite-Sheet Probleme:**
- Jede Animation = neue PNG mit allen Frames
- Artist muss perfekt zeichnen können (limitierend!)
- Memory-Overhead (viele große Texturen)
- Schwer zu variieren (Caprica in anderem Outfit? Neue Frames!)
- NPCs brauchen separate Sprite-Sheets

✅ **Paperdoll Lösung:**
- Animation ist **Knochen-basiert** (Bones bewegen sich, nicht Sprites)
- Assets sind einfach **PNG-Teile** (Head, Arm, Leg, Torso)
- Ein Rig kann von jedem Character verwendet werden
- Artist braucht nur Basis-Anatomie verstehen (nicht perfekte Keyframe-Kunst)
- Memory-Effizient (weniger Texturen, mehr Reuse)

### Warum das für CapricaGame Perfekt Ist

1. **Limitierte Pixel-Art-Fähigkeiten sind okay** – Man braucht nur saubere Grafiken, nicht animation-ready pixel art
2. **NPCs sind "kostenlos"** – Gleicher Rig, andere Body-Parts
3. **Dynamische Variationen möglich** – Equipment/Skins ohne neuer Animation
4. **Schneller zu iterieren** – Bone-Animation in Godot tweaken ist schneller als Frames redraw

---

## Architecture: Godot Bone2D System

### Level 1: Asset Structure

```
res/Assets/Characters/Paperdolls/
├── Caprica/
│   ├── Head.png           (Gesicht, Haare)
│   ├── Torso.png          (Oberkörper)
│   ├── ArmUpper_L.png     (Oberarm links)
│   ├── ArmUpper_R.png     (Oberarm rechts)
│   ├── ArmLower_L.png     (Unterarm links)
│   ├── ArmLower_R.png     (Unterarm rechts)
│   ├── Hand_L.png         (Hand links)
│   ├── Hand_R.png         (Hand rechts)
│   ├── HipPelvis.png      (Becken)
│   ├── LegUpper_L.png     (Oberschenkel links)
│   ├── LegUpper_R.png     (Oberschenkel rechts)
│   ├── LegLower_L.png     (Unterschenkel links)
│   ├── LegLower_R.png     (Unterschenkel rechts)
│   ├── Foot_L.png         (Fuß links)
│   └── Foot_R.png         (Fuß rechts)
│
├── SLOBZombie/
│   ├── Head.png
│   ├── Torso.png
│   └── ... (same structure)
│
└── Shared/
    ├── Boots_A.png        (Reusable Equipment)
    ├── Jacket_A.png
    └── Hat_A.png
```

**Key Insight:** Body-Parts sind **unabhängige PNG-Dateien**, die via Godot zusammengefügt werden (nicht vorgerendert).

---

### Level 2: Bone Hierarchy in Godot

**Godot 4.5 Struktur (Skeleton2D + Bone2D):**

```
CharacterRoot (Node2D)
├── Skeleton2D
│   ├── Bone (Root)
│   │   ├── Bone (Torso)
│   │   │   ├── Bone (ArmUpper_L)
│   │   │   │   ├── Bone (ArmLower_L)
│   │   │   │   │   └── Bone (Hand_L)
│   │   │   ├── Bone (ArmUpper_R)
│   │   │   │   ├── Bone (ArmLower_R)
│   │   │   │   │   └── Bone (Hand_R)
│   │   │   ├── Bone (Head)
│   │   │   └── Bone (HipPelvis)
│   │   │       ├── Bone (LegUpper_L)
│   │   │       │   ├── Bone (LegLower_L)
│   │   │       │   │   └── Bone (Foot_L)
│   │   │       ├── Bone (LegUpper_R)
│   │   │       │   ├── Bone (LegLower_R)
│   │   │       │   │   └── Bone (Foot_R)
│   │   │       └── Bone (Tail) [optional]
│   │
│   └── [Sprite2D für jedes Body-Part, jeweils an Bone gebunden]
```

**Wichtig:** Jedes Sprite2D wird an ein Bone gekoppelt → Bone-Rotation = Sprite-Rotation

---

### Level 3: GDScript Controller

```gdscript
# character_animancer.gd
extends Node2D

class_name CharacterAnimancer

## Bone-Zugriff
@onready var skeleton: Skeleton2D = $Skeleton2D
var bone_roots: Dictionary = {}

## Animation-State
var current_animation: String = "idle"
var animation_progress: float = 0.0
var is_playing: bool = false

## Animation-Daten (Curves für jedes Bone)
var animation_library: Dictionary = {}

func _ready() -> void:
    _cache_bones()
    _load_animation_library()

# Alle Bones in Dictionary speichern für schnellen Zugriff
func _cache_bones() -> void:
    var skeleton_bones = skeleton.get_bones()
    for bone_idx in skeleton_bones:
        var bone = skeleton.get_bone(bone_idx)
        bone_roots[bone.name] = bone_idx

# Animation-Library laden (z.B. aus JSON oder Curves)
func _load_animation_library() -> void:
    animation_library = {
        "idle": {
            "torso": create_idle_curve(),
            "head": create_breathing_curve(),
            # ... mehr bones
        },
        "walk": {
            "leg_upper_l": create_walk_leg_curve(),
            "leg_upper_r": create_walk_leg_curve(offset=0.5),
            # ... mehr bones
        },
    }

# Animation spielen
func play_animation(anim_name: String, speed: float = 1.0) -> void:
    if anim_name not in animation_library:
        push_error("Animation '%s' nicht gefunden" % anim_name)
        return

    current_animation = anim_name
    animation_progress = 0.0
    is_playing = true

# Update in _process
func _process(delta: float) -> void:
    if not is_playing:
        return

    animation_progress += delta

    var anim_data = animation_library[current_animation]
    for bone_name: String in anim_data:
        var curve = anim_data[bone_name]
        var bone_idx = bone_roots.get(bone_name, -1)

        if bone_idx == -1:
            continue

        # Curve-Sample (0.0-1.0 normalisiert)
        var sample_pos = fmod(animation_progress, curve.max_value)
        var rotation_value = curve.sample(sample_pos)

        skeleton.set_bone_pose(bone_idx, Transform2D(
            rotation_value,
            skeleton.get_bone_pose(bone_idx).origin
        ))

    # Animation-Ende
    if animation_progress > _get_animation_length(current_animation):
        is_playing = false

# Hilfsfunktion: Animation-Länge
func _get_animation_length(anim_name: String) -> float:
    # Von Meta oder hardcodiert
    return 1.0  # 1 Sekunde

# Animation-Curves erstellen (einfaches Beispiel: Idle Breathing)
func create_idle_curve() -> Curve:
    var curve = Curve.new()
    curve.add_point(Vector2(0.0, 0.0))      # Start
    curve.add_point(Vector2(0.25, 0.02))    # Einatmen
    curve.add_point(Vector2(0.5, 0.0))      # Mitte
    curve.add_point(Vector2(0.75, -0.02))   # Ausatmen
    curve.add_point(Vector2(1.0, 0.0))      # Ende (loop)
    return curve
```

---

## Animation Creation Workflow

### Step 1: Assets Vorbereiten

1. **Body-Parts zeichnen/sammeln** (Pixel-Art, AI-Generated, whatever)
   - Größe: 64x64 oder 128x128 (skalierbar)
   - Transparenz: PNG mit Alpha-Channel
   - Ausrichtung: Neutral/Symmetrisch (nicht "animated")
   - Pivot-Point: Gelenk-Position (z.B. Hand: Handgelenk oben-links)

2. **In Godot importieren**
   - Filter: Point (für Pixel-Art)
   - Canvas-Items → Texture Filter auf Nearest

### Step 2: Bones Setup in Godot

1. **Skeleton2D Scene erstellen**
   - Neue Scene: Skeleton2D Root
   - Bone erstellen für jeden Body-Part
   - Bone-Rotation-Limits setzen (z.B. Arm kann nicht 360° rotieren)

2. **Sprites an Bones binden**
   - Für jedes Body-Part: Sprite2D erstellen
   - Sprite als Child des entsprechenden Bones
   - Pivot anpassen (z.B. Hand-Pivot = Handgelenk)

### Step 3: Animation-Curves Erstellen

**Option A: Animation-Curves in Godot Editor**
```gdscript
# Godot exportiert Animation-Daten direkt
var idle_animation = {
    "duration": 2.0,
    "bones": {
        "torso": Curve.new(),  # Aus Editor erstellt
        "head": Curve.new(),
        # ...
    }
}
```

**Option B: Custom-Format (z.B. JSON)**
```json
{
  "animations": {
    "idle": {
      "duration": 2.0,
      "bones": {
        "torso": {
          "keyframes": [
            { "time": 0.0, "rotation": 0.0 },
            { "time": 0.5, "rotation": 0.05 },
            { "time": 1.0, "rotation": 0.0 }
          ]
        }
      }
    }
  }
}
```

### Step 4: Spielen & Iterieren

```gdscript
# In Player oder Character-Script
func _process(delta: float) -> void:
    if Input.is_action_pressed("move_right"):
        animancer.play_animation("walk", speed=1.5)
    elif Input.is_action_pressed("jump"):
        animancer.play_animation("jump")
    else:
        animancer.play_animation("idle")
```

---

## Animation Examples für CapricaGame

### Idle (2 Sekunden Loop)

```
Time  Head    Torso   Arms       Legs       Description
0.0   0°      0°      0°/0°      0°/0°      Start (neutral)
0.5   0.02°   0°      ±0.01°     0°/0°      Breathing (subtil)
1.0   0°      0°      0°/0°      0°/0°      Mitte
1.5   -0.02°  0°      ±0.01°     0°/0°      Ausatmen
2.0   0°      0°      0°/0°      0°/0°      Loop-Start
```

### Walk (1.2 Sekunden, für beide Beine offset 0.6s)

```
Time  LegL    LegR    ArmL   ArmR   Torso   Desc
0.0   0°      0°      0°     0°     0°      Start
0.3   +25°    -5°     -15°   +15°   ±2°     Links vorne
0.6   0°      0°      0°     0°     0°      Beide zentriert
0.9   -5°     +25°    +15°   -15°   ±2°     Rechts vorne
1.2   0°      0°      0°     0°     0°      Loop
```

### Jump (0.8 Sekunden total)

```
Time  Phase       Arms    Legs    Desc
0.0-0.2  Startup  ↑       ↓       Arms up, legs bent
0.2-0.5  Airborne ↑       ↑       Fully extended
0.5-0.8  Landing  →       ↓       Arms settle, legs absorb
```

### Kick Attack (0.6 Sekunden)

```
Time  Torso   Arm    Leg       Desc
0.0   0°      0°     0°        Start pose
0.2   -10°    +20°   +60° (L)  Windup
0.3   +5°     -10°   +90° (L)  Full extension [HITBOX ACTIVE]
0.5   -5°     0°     +30° (L)  Retraction
0.6   0°      0°     0°        End
```

---

## Reusability: NPC Zombie mit gleichem Rig

```gdscript
# zombie.gd
extends CharacterBody2D

@onready var animancer = $Skeleton2D/CharacterAnimancer

func _ready() -> void:
    # GLEICHER CharacterAnimancer-Klasse!
    # Nur andere Body-Parts PNG-Dateien:
    animancer.load_spritesheet_for_character("SLOBZombie")
    animancer.play_animation("zombie_idle")

func _process(delta: float) -> void:
    # Zombie wandert zufällig
    if randf() > 0.95:
        animancer.play_animation("walk")
    else:
        animancer.play_animation("idle")
```

**Benefit:** Zombie ist nicht "ein separates Code-System" – es verwendet exakt den gleichen Animancer, nur mit anderen Assets!

---

## Performance Considerations

### Memory
- **Sprite Sheets:** 2-3 MB pro Character (alle Frames vorgerendert)
- **Paperdoll:** ~200-400 KB pro Character (nur Body-Parts)
- **Savings:** ~80% Memory-Reduction

### CPU
- **Sprite Animation:** Einfach (nur Frame-Index wechseln)
- **Bone Animation:** Etwas komplexer (Bone-Rotationen berechnen)
- **Real-World:** Negligible auf modernen Maschinen (~0.2-0.5ms pro Character)

### Optimisierungen
- Bones nur updaten die sich ändern (Skip static Bones)
- Curve-Sampling mit vorberechneten Werten (statt realtim Berechnung)
- Skeleton2D ist Godot-optimiert – nutzen!

---

## Potential Issues & Lösungen

| Problem | Ursache | Lösung |
|---------|--------|--------|
| Knochenwinkel falsch | Pivot-Point nicht an Gelenk | Pivot in Sprite anpassen |
| Animation sieht "jittery" | Zu wenige Keyframes | Mehr Zwischenwerte hinzufügen |
| Performance-Drop | Zu viele Bones | Bones mergen (z.B. Hand+Arm) |
| Aussehen "steif" | Lineare Interpolation | Easing-Kurven verwenden (ease-in/out) |
| Overlap bei Bewegung | Sprite-Z-Ordering falsch | Correct Z-Index per Bone-Depth |

---

## Tools & Ressourcen

### Godot Features
- **Skeleton2D:** Bone-Hierarchie
- **Bone2D:** Einzelne Bones mit Limits
- **Curve:** Smooth Animation-Keyframes

### Externe Tools (optional)
- **Aseprite:** Pixel-Art mit Bone-Export (Pro)
- **Spine:** Komplexes Rigging (overkill für CapricaGame)
- **Blender:** 2D Skeletal Animation (kostenlos, komplex)

Für CapricaGame: **Godot-native Curves genügen!**

---

## Mercury 0 Checklist

- [ ] Caprica Body-Parts (Head, Torso, Arms, Legs) als PNG erstellen/sammeln
- [ ] Skeleton2D Scene mit Bone-Hierarchie aufsetzen
- [ ] CharacterAnimancer GDScript implementieren
- [ ] Idle-Animation mit Breathing-Curve erstellen
- [ ] Walk-Cycle-Animation erstellen (forward + backward)
- [ ] Jump-Animation (startup/airborne/landing phases)
- [ ] Kick-Animation mit Hitbox-Timing
- [ ] SLOBZombie mit gleichem Rig testen (nur andere Assets)
- [ ] Performance-Test (ist 60fps mit 10 Characters möglich?)
- [ ] Debug-Visualization (Bones sichtbar machen zum Debuggen)

**Ziel nach Mercury 0:** Caprica kann idle rumstehen, laufen, springen, attackieren. Alles sieht flüssig und "gut" aus.

---

## Version History

**v1.0** – 30. Dezember 2025
Initial Paperdoll Animation Architecture für CapricaGame

---

## Weitere Ressourcen

- Godot Skeleton2D Docs: https://docs.godotengine.org/en/stable/classes/class_skeleton2d.html
- Animation Best Practices: [MOTOR_ANIMATION.md](MOTOR_ANIMATION.md)
