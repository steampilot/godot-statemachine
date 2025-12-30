# Mercury 0: Implementation Guide

**Vom Default Warrior → zu Caprica Game Avatar**

*Der praktische Anfang von deinem eigenen Spiel*

---

## Schritt 1: Caprica Paperdoll Assets vorbereiten

### 1.1 Assets sammeln / erstellen

Du brauchst **einzelne PNG-Dateien** für jeden Body-Part:

```
res/Assets/Characters/Paperdolls/Caprica/
├── Head.png           (Gesicht, Haare)
├── Torso.png          (Oberkörper, Brust)
├── ArmUpper_L.png     (Oberarm links)
├── ArmUpper_R.png     (Oberarm rechts)
├── ArmLower_L.png     (Unterarm links)
├── ArmLower_R.png     (Unterarm rechts)
├── Hand_L.png         (Hand links)
├── Hand_R.png         (Hand rechts)
├── HipPelvis.png      (Becken)
├── LegUpper_L.png     (Oberschenkel links)
├── LegUpper_R.png     (Oberschenkel rechts)
├── LegLower_L.png     (Unterschenkel links)
├── LegLower_R.png     (Unterschenkel rechts)
├── Foot_L.png         (Fuß links)
└── Foot_R.png         (Fuß rechts)
```

**Optionen:**
- ✅ Aus `doc/Concept Art/` verwenden (falls vorhanden)
- ✅ KI-generiert (z.B. Midjourney, DALL-E)
- ✅ Von Hand gezeichnet
- ✅ Temporär: Einfache Platzhalter (farbige Rechtecke) zum Testen

**Wichtig:**
- Größe: 64x64 oder 128x128 Pixel (später skalierbar)
- Format: PNG mit Transparenz (Alpha-Channel)
- Pivot-Point: Gelenk-Position (z.B. Hand: Handgelenk oben-links)
- Ausrichtung: Neutral/Symmetrisch (nicht "animated")

---

## Schritt 2: Godot Scene für Caprica Bone2D Setup

### 2.1 Neue Scene erstellen: `res/Scenes/caprica_paperdoll.tscn`

```gdscript
# caprica_paperdoll.tscn Struktur (in Godot Editor):

Node2D (Root)
├── Skeleton2D
│   ├── Bone2D (Root)
│   │   ├── Bone2D (Torso)
│   │   │   ├── Bone2D (ArmUpper_L)
│   │   │   │   ├── Bone2D (ArmLower_L)
│   │   │   │   │   └── Bone2D (Hand_L)
│   │   │   ├── Bone2D (ArmUpper_R)
│   │   │   │   ├── Bone2D (ArmLower_R)
│   │   │   │   │   └── Bone2D (Hand_R)
│   │   │   ├── Bone2D (Head)
│   │   │   └── Bone2D (HipPelvis)
│   │   │       ├── Bone2D (LegUpper_L)
│   │   │       │   ├── Bone2D (LegLower_L)
│   │   │       │   │   └── Bone2D (Foot_L)
│   │   │       ├── Bone2D (LegUpper_R)
│   │   │       │   ├── Bone2D (LegLower_R)
│   │   │       │   │   └── Bone2D (Foot_R)
│   │
│   └── Sprite2D (für jedes Body-Part, jeweils an Bone2D gebunden)
```

**Praktischer Workflow im Godot Editor:**

1. **Neuer Scene Root:** Node2D, benenne ihn "Caprica"
2. **Child: Skeleton2D** hinzufügen
3. **In Skeleton2D: Bone2D erstellen** (Root Bone)
4. **Bones hierarchisch aufbauen:**
   - Root
     - Torso (Position: ~Center)
       - ArmUpper_L (Position: Schulter-Links)
       - ArmUpper_R (Position: Schulter-Rechts)
       - Head (Position: Hals)
       - HipPelvis (Position: Hüfte)
         - LegUpper_L (Position: Hüfte-Links)
         - LegUpper_R (Position: Hüfte-Rechts)

5. **Für jedes Bone: Sprite2D Kind hinzufügen**
   - Sprite2D(Head) → Texture = Head.png
   - Sprite2D(Torso) → Texture = Torso.png
   - etc.

6. **Pivot-Points anpassen:**
   - Sprite2D Offset = Gelenk-Position
   - z.B. Hand: Offset.y = -32 (Handgelenk oben)

---

## Schritt 3: GDScript Animancer für Caprica

### 3.1 `res/Scripts/caprica_animancer.gd` erstellen

```gdscript
extends Node2D

class_name CapricaAnimancer

# Skeleton-Zugriff
@onready var skeleton: Skeleton2D = $Skeleton2D
var bone_dict: Dictionary = {}  # name -> bone_index

# Animation-State
var current_animation: String = "idle"
var animation_progress: float = 0.0
var is_playing: bool = false

# Animation-Curves (einfache Version)
var animations: Dictionary = {}

func _ready() -> void:
	_setup_bones()
	_create_animations()
	play_animation("idle")

# Cache alle Bones
func _setup_bones() -> void:
	for i in range(skeleton.get_bone_count()):
		var bone = skeleton.get_bone(i)
		bone_dict[bone.name] = i

# Einfache Idle-Animation (Breathing)
func _create_animations() -> void:
	animations["idle"] = {
		"duration": 2.0,
		"bones": {
			"Head": create_breathing_curve(),
			"Torso": create_idle_curve(),
		}
	}

	animations["walk"] = {
		"duration": 1.2,
		"bones": {
			"LegUpper_L": create_walk_leg_curve(0.0),
			"LegUpper_R": create_walk_leg_curve(0.6),
			"Torso": create_walk_torso_curve(),
		}
	}

	animations["jump"] = {
		"duration": 0.8,
		"bones": {
			"LegUpper_L": create_jump_leg_curve(),
			"LegUpper_R": create_jump_leg_curve(),
		}
	}

# Animation abspielen
func play_animation(anim_name: String) -> void:
	if anim_name not in animations:
		push_error("Animation '%s' nicht gefunden" % anim_name)
		return

	current_animation = anim_name
	animation_progress = 0.0
	is_playing = true

# Update-Loop
func _process(delta: float) -> void:
	if not is_playing:
		return

	animation_progress += delta
	var anim_data = animations[current_animation]
	var duration = anim_data["duration"]

	# Animation-Bytes
	var t = fmod(animation_progress, duration) / duration  # 0.0 - 1.0

	for bone_name: String in anim_data["bones"]:
		if bone_name not in bone_dict:
			continue

		var bone_idx = bone_dict[bone_name]
		var curve = anim_data["bones"][bone_name]
		var rotation_value = curve.sample(t)

		var pose = skeleton.get_bone_pose(bone_idx)
		skeleton.set_bone_pose(bone_idx, Transform2D(
			rotation_value,
			pose.origin
		))

# Einfache Curves für verschiedene Animationen
func create_idle_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.5, 0.0))
	curve.add_point(Vector2(1.0, 0.0))
	return curve

func create_breathing_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.25, 0.05))   # Einatmen
	curve.add_point(Vector2(0.5, 0.0))
	curve.add_point(Vector2(0.75, -0.05))  # Ausatmen
	curve.add_point(Vector2(1.0, 0.0))
	return curve

func create_walk_leg_curve(offset: float = 0.0) -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(offset, 0.0))
	curve.add_point(Vector2(fmod(offset + 0.25, 1.0), 0.5))    # Vorne
	curve.add_point(Vector2(fmod(offset + 0.5, 1.0), 0.0))
	curve.add_point(Vector2(fmod(offset + 0.75, 1.0), -0.5))   # Hinten
	curve.add_point(Vector2(fmod(offset + 1.0, 1.0), 0.0))
	return curve

func create_walk_torso_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.25, 0.05))
	curve.add_point(Vector2(0.5, 0.0))
	curve.add_point(Vector2(0.75, -0.05))
	curve.add_point(Vector2(1.0, 0.0))
	return curve

func create_jump_leg_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, -0.5))     # Startup (gebeugt)
	curve.add_point(Vector2(0.2, 0.0))      # Extension
	curve.add_point(Vector2(0.5, 0.0))      # Airborne
	curve.add_point(Vector2(0.8, -0.3))     # Landing (Absorption)
	curve.add_point(Vector2(1.0, 0.0))      # End
	return curve
```

---

## Schritt 4: Caprica ins Spiel integrieren

### 4.1 `res/Scenes/player.tscn` updaten

**Jetzt:** Der alte Warrior mit Sprite Sheets
**Neu:** Caprica mit Paperdoll

Option A: **Einfach ersetzen**
- Alt-Scene Content löschen (Sprites, AnimationPlayer mit Warrior Frames)
- `caprica_paperdoll.tscn` als Instance hinzufügen
- Script bleibt gleich (nur Sprite-Referenzen updaten)

Option B: **Hybrid (sicherer)**
- Neuen Player erstellen: `res/Scenes/caprica_player.tscn`
- Struktur kopieren, aber mit Caprica-Avatar
- Alte `player.tscn` als Fallback behalten (für schnellen Rollback)

---

## Schritt 5: Test-Script für Mercury 0

### 5.1 `res/Scripts/mercury_0_test.gd` erstellen

```gdscript
extends Node

@onready var caprica: CapricaAnimancer = $Caprica

func _ready() -> void:
	print("🎸 Mercury 0 Test: Caprica Animations")
	print("Press I = Idle, W = Walk, J = Jump")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_i"):
		print("Playing: idle")
		caprica.play_animation("idle")

	if Input.is_action_just_pressed("ui_w"):
		print("Playing: walk")
		caprica.play_animation("walk")

	if Input.is_action_just_pressed("ui_j"):
		print("Playing: jump")
		caprica.play_animation("jump")
```

---

## Checklist: Mercury 0 Implementation

- [ ] **Assets:** Caprica Body-Parts PNGs erstellt/gesammelt
- [ ] **Ordner-Struktur:** `res/Assets/Characters/Paperdolls/Caprica/` mit allen Parts
- [ ] **Scene:** `caprica_paperdoll.tscn` mit Skeleton2D + Bone-Hierarchie
- [ ] **Script:** `caprica_animancer.gd` implementiert
- [ ] **Integration:** Player nutzt Caprica (nicht Warrior)
- [ ] **Test:** Idle/Walk/Jump Animations funktionieren
- [ ] **Zombie:** Zombie auch mit Caprica-Rig testen (reusability!)

---

## Quick-Start: Wenn Assets noch nicht bereit

**Temporär:** Placeholder-Bones nutzen (ohne Sprites)

```gdscript
# In caprica_animancer.gd:
# Statt:
# var pose = skeleton.get_bone_pose(bone_idx)

# Temporär nur Rotation, keine Sprites:
# Das visualisiert die Bone-Bewegung im Editor!
```

**Davon:** Debug View im Godot Editor zeigt Bones → verfizierbar!

---

## Danach: Mercury 1

Nach Mercury 0 hast du:
✅ Caprica mit funktionierendem Bone2D-Rig
✅ Idle/Walk/Jump Animations
✅ Modularer Animancer für zukünftige Animationen

**Nächster Schritt:** Mercury 1 (Beat Detection)

---

**Version:** 1.0
**Status:** Ready to Start
**Erstellt:** 30. Dezember 2025
