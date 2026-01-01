# Mercury Mission 1: Caprica Paperdoll Avatar

**Start Date:** 01.01.2026, 10:13  
**Status:** In Progress  
**Priorität:** Kritisch – Foundation für alle Character-Animation  
**Geschätzte Dauer:** 2-3 Tage  
**Abhängigkeiten:** Keine

---

## Mission Objective

Erstelle **Caprica's Bone2D Paperdoll Rig** mit grundlegenden Animationen:
- Idle (Breathing)
- Walk (Links/Rechts)
- Jump (Startup/Airborne/Landing)

**Erfolgs-Kriterium:**  
Caprica steht im Level, atmet subtil, kann laufen und springen – **und es sieht gut aus**.

---

## Warum Paperdoll statt Sprite Sheet?

✅ **Vorteile:**
- Wiederverwendbares Rig für NPCs (Steampilot, Zombies, Bosse)
- Equipment/Outfit-Swaps ohne neue Animationen
- Schneller zu iterieren (Bone-Tweaking vs. Pixel-Redraw)
- Geringerer Memory-Footprint
- Artist braucht nur Basis-PNG-Parts, keine Frame-perfekten Sprite Sheets

❌ **Nachteile (akzeptiert):**
- Lerncurve für Bone2D Animation
- Kein klassischer Pixel-Art Look

**Entscheidung:** Paperdoll, weil Flexibilität > klassischer Look.

---

## Phase 1: Asset Check (✅ Erledigt)

### Was existiert bereits:
```
res/Assets/Characters/Paperdolls/Caprica/
├── Head.png              ✅
├── Hair.png              ✅
├── Torso.png             ✅
├── TorsoBack.png         ✅
├── Midriff.png           ✅
├── Skirt.png             ✅
├── LeftUpperArm.png      ✅
├── LeftLowerArm.png      ✅
├── LeftHand.png          ✅
├── RightUpperArm.png     ✅
├── RightLowerArm.png     ✅
├── RightHand.png         ✅
├── LeftUpperLeg.png      ✅
├── LeftLowerLeg.png      ✅
├── LeftFoot.png          ✅
├── RightUpperLeg.png     ✅
├── RightLowerLeg.png     ✅
├── RightFoot.png         ✅
```

**Status:** Alle Body-Parts vorhanden! 🎉

### Zusätzliche Assets:
- `CapricaPaperDoll.png` (Gesamt-Reference)
- `CapricaPaperDoll_Scaled.png` (Skalierte Version)
- `CapricaHeadFront/ToLeft/ToRight.png` (Head Rotations für Parallax)

**Nächster Schritt:** Rig aufbauen.

---

## Phase 2: Skeleton2D Setup (Heute!)

### Ziel
Erstelle das **Bone2D Rig** in Godot, das alle Body-Parts verbindet.

### Scene Structure

```
CapricaAvatar (Node2D)
├── Skeleton2D
│   ├── BoneRoot (Bone2D)
│   │   ├── BoneHips (Bone2D)
│   │   │   ├── BoneSpine (Bone2D)
│   │   │   │   ├── BoneChest (Bone2D)
│   │   │   │   │   ├── BoneNeck (Bone2D)
│   │   │   │   │   │   └── BoneHead (Bone2D)
│   │   │   │   │   ├── BoneShoulderL (Bone2D)
│   │   │   │   │   │   ├── BoneUpperArmL (Bone2D)
│   │   │   │   │   │   │   ├── BoneLowerArmL (Bone2D)
│   │   │   │   │   │   │   │   └── BoneHandL (Bone2D)
│   │   │   │   │   ├── BoneShoulderR (Bone2D)
│   │   │   │   │   │   ├── BoneUpperArmR (Bone2D)
│   │   │   │   │   │   │   ├── BoneLowerArmR (Bone2D)
│   │   │   │   │   │   │   │   └── BoneHandR (Bone2D)
│   │   │   ├── BoneHipL (Bone2D)
│   │   │   │   ├── BoneUpperLegL (Bone2D)
│   │   │   │   │   ├── BoneLowerLegL (Bone2D)
│   │   │   │   │   │   └── BoneFootL (Bone2D)
│   │   │   ├── BoneHipR (Bone2D)
│   │   │   │   ├── BoneUpperLegR (Bone2D)
│   │   │   │   │   ├── BoneLowerLegR (Bone2D)
│   │   │   │   │   │   └── BoneFootR (Bone2D)
├── Sprites (Node2D) [Z-Sorting Layer]
│   ├── TorsoBack (Sprite2D)  [Z-Index: -1]
│   ├── RightUpperArm (Sprite2D)  [Z-Index: -1]
│   ├── RightLowerArm (Sprite2D)  [Z-Index: -1]
│   ├── RightHand (Sprite2D)  [Z-Index: -1]
│   ├── RightUpperLeg (Sprite2D)  [Z-Index: -1]
│   ├── RightLowerLeg (Sprite2D)  [Z-Index: -1]
│   ├── RightFoot (Sprite2D)  [Z-Index: -1]
│   ├── Midriff (Sprite2D)  [Z-Index: 0]
│   ├── Torso (Sprite2D)  [Z-Index: 0]
│   ├── Skirt (Sprite2D)  [Z-Index: 0]
│   ├── Head (Sprite2D)  [Z-Index: 1]
│   ├── Hair (Sprite2D)  [Z-Index: 2]
│   ├── LeftUpperArm (Sprite2D)  [Z-Index: 1]
│   ├── LeftLowerArm (Sprite2D)  [Z-Index: 1]
│   ├── LeftHand (Sprite2D)  [Z-Index: 1]
│   ├── LeftUpperLeg (Sprite2D)  [Z-Index: 0]
│   ├── LeftLowerLeg (Sprite2D)  [Z-Index: 0]
│   └── LeftFoot (Sprite2D)  [Z-Index: 0]
```

### Z-Index Regel (Wichtig für Depth-Sorting!)

**Hinter Körper (Z-Index: -1):**
- Rechter Arm (wenn Caprica nach links schaut)
- Rechtes Bein (wenn Caprica nach links schaut)
- TorsoBack (Optional für "Jacke hinten"-Effekt)

**Körper Mitte (Z-Index: 0):**
- Torso, Midriff, Skirt
- Beine (wenn keine Tiefe nötig)

**Vor Körper (Z-Index: 1-2):**
- Head, Hair
- Linker Arm (wenn Caprica nach links schaut)

**Wichtig:** Z-Index muss **dynamisch wechseln**, wenn Caprica Richtung ändert (später in Phase 4).

---

### Bone Attachment Process

Jedes **Sprite2D** muss mit einem **Bone2D** verbunden werden:

1. Sprite2D erstellen
2. Texture laden (z.B. `LeftUpperArm.png`)
3. **Offset setzen:** `Offset` Property anpassen, sodass Rotation-Pivot am Gelenk ist (nicht Center)
4. **Skeleton Path setzen:** `Skeleton2D` NodePath im Sprite2D Inspector
5. **Bone Name setzen:** Bone-Name im Sprite2D Inspector (z.B. `BoneUpperArmL`)

**Godot macht dann automatisch:**
- Sprite folgt Bone-Position
- Sprite rotiert mit Bone-Rotation

---

### Schritt-für-Schritt Rig-Aufbau

#### 1. Skeleton2D erstellen
- Node hinzufügen: `Skeleton2D`
- Root-Node: `CapricaAvatar (Node2D)`

#### 2. Root Bone erstellen
- Child von Skeleton2D: `Bone2D` (Name: `BoneRoot`)
- Position: Center of Mass (etwa Hüfte)

#### 3. Spine Chain aufbauen
```
BoneRoot → BoneHips → BoneSpine → BoneChest → BoneNeck → BoneHead
```

**Positions (Pixel-Approximate):**
- BoneHips: (0, 0) [Root]
- BoneSpine: (0, -20)
- BoneChest: (0, -40)
- BoneNeck: (0, -60)
- BoneHead: (0, -80)

**Rest Pose:**
- Alle Rotationen = 0°
- Aufrecht stehend

#### 4. Arm Chain (Linke Seite)
```
BoneChest → BoneShoulderL → BoneUpperArmL → BoneLowerArmL → BoneHandL
```

**Positions:**
- BoneShoulderL: (-15, -50)
- BoneUpperArmL: (-15, -40)
- BoneLowerArmL: (-15, -20)
- BoneHandL: (-15, -5)

**Rest Pose:**
- Arm hängt locker neben Körper
- Slight Bend im Ellbogen (10-15°)

#### 5. Arm Chain (Rechte Seite)
- Spiegele Left-Side (X-Position invertieren)

#### 6. Leg Chain (Linke Seite)
```
BoneHips → BoneHipL → BoneUpperLegL → BoneLowerLegL → BoneFootL
```

**Positions:**
- BoneHipL: (-8, 0)
- BoneUpperLegL: (-8, 20)
- BoneLowerLegL: (-8, 40)
- BoneFootL: (-8, 60)

**Rest Pose:**
- Beine gerade stehend
- Slight Bend im Knie (5°)

#### 7. Leg Chain (Rechte Seite)
- Spiegele Left-Side

---

### Sprites an Bones attachen

**Für jeden Body-Part:**

1. Erstelle `Sprite2D` Node unter `Sprites` Container
2. Lade Texture (z.B. `res://Assets/Characters/Paperdolls/Caprica/LeftUpperArm.png`)
3. **Setze Offset:**
   - Obere Gelenke (Schulter, Hüfte): Offset oben
   - Untere Gelenke (Ellbogen, Knie): Offset Mitte
   - Enden (Hand, Fuß): Offset oben
4. **Skeleton Path:** `../Skeleton2D`
5. **Bone Name:** z.B. `BoneUpperArmL`
6. **Z-Index setzen** (siehe oben)

**Test:**
- Bone2D bewegen/rotieren im Editor
- Sprite sollte mitfolgen

---

### Deliverables Phase 2
- ✅ Skeleton2D mit kompletter Bone-Hierarchy
- ✅ Alle Sprites an Bones attached
- ✅ Z-Index korrekt (keine clipping issues)
- ✅ Rest Pose sieht natürlich aus

---

## Phase 3: Idle Animation (Tag 1 Nachmittag)

### Ziel
Erstelle **Idle-Animation** mit subtiler Atmung (Breathing).

### Animation Setup

1. Erstelle `AnimationPlayer` Node
2. Neue Animation: `idle` (Length: 2.0s, Loop: On)

### Animation Tracks

#### Track 1: Breathing (Chest/Torso)
```
BoneChest - Rotation
  0.0s:  0°
  1.0s:  2°
  2.0s:  0°
```

**Easing:** Ease In/Out (smooth breathing)

#### Track 2: Subtle Sway (Head)
```
BoneHead - Rotation
  0.0s:  0°
  1.0s: -1°
  2.0s:  0°
```

#### Track 3: Arms (slight movement)
```
BoneUpperArmL - Rotation
  0.0s:  0°
  1.5s:  1°
  2.0s:  0°

BoneUpperArmR - Rotation
  0.0s:  0°
  1.5s: -1°
  2.0s:  0°
```

**Wichtig:** Movements sind SUBTIL (1-2° max). Zu viel = unruhig.

### Test
- Play Animation in Godot
- Sollte wie "character is waiting" aussehen
- Breathing sollte sichtbar, aber nicht übertrieben sein

### Deliverables Phase 3
- ✅ Idle Animation funktioniert
- ✅ Breathing sieht natürlich aus
- ✅ Kein "jittering" oder abrupte Bewegungen

---

## Phase 4: Walk Animation (Tag 2 Vormittag)

### Ziel
Erstelle **Walk Cycle** (Left/Right).

### Animation Setup

1. Neue Animation: `walk` (Length: 0.8s, Loop: On)

### Walk Cycle Phasen

#### Frame 0.0s: Contact
- Linkes Bein vorne (BoneUpperLegL: -20°)
- Rechtes Bein hinten (BoneUpperLegR: 20°)
- Linker Arm hinten (BoneUpperArmL: 20°)
- Rechter Arm vorne (BoneUpperArmR: -20°)

#### Frame 0.2s: Down
- Beide Beine leicht gebeugt (BoneLowerLegL/R: -10°)
- Hips senken (BoneHips: Y+2)

#### Frame 0.4s: Passing
- Beine überkreuzen (beide 0°)
- Hips normal (Y+0)

#### Frame 0.6s: Up
- Rechtes Bein vorne (BoneUpperLegR: -20°)
- Linkes Bein hinten (BoneUpperLegL: 20°)
- Rechter Arm hinten (BoneUpperArmR: 20°)
- Linker Arm vorne (BoneUpperArmL: -20°)

#### Frame 0.8s: Contact (Loop)
- Zurück zu Frame 0.0s

### Zusätzliche Details

**Torso:**
- Slight rotation während Walk (BoneChest: ±3°)
- Gives "weight" to movement

**Head:**
- Slight counter-rotation (BoneHead: ±2°, entgegengesetzt zu Chest)

**Arms:**
- Swing amplitude: 20-30°
- Hands stay relaxed (no extra rotation)

**Legs:**
- Knee Bend während Down-Phase (BoneLowerLeg: -15° to -20°)
- Foot stays flat on ground (BoneFoot: 0°)

### Test
- Walk Animation im AnimationPlayer loopen
- Sollte smooth aussehen (kein "popping")
- Timing anpassen, falls zu schnell/langsam

### Deliverables Phase 4
- ✅ Walk Cycle funktioniert
- ✅ Loop ist seamless (kein "snap" zurück zu Frame 0)
- ✅ Arms/Legs sind koordiniert (opposite arm/leg forward)

---

## Phase 5: Jump Animation (Tag 2 Nachmittag)

### Ziel
Erstelle **Jump Sequence** (Startup → Airborne → Landing).

### Animation Setup

Drei separate Animationen (nicht geloopt):

1. `jump_startup` (0.2s)
2. `jump_airborne` (Loop, für mid-air)
3. `jump_landing` (0.3s)

---

### Animation 1: Jump Startup

**Duration:** 0.2s (kein Loop)

**Keyframes:**

#### Frame 0.0s: Crouch
- Hips down (BoneHips: Y+8)
- Legs bent (BoneLowerLegL/R: -45°)
- Arms back (BoneUpperArmL/R: 30°)
- Chest forward (BoneChest: 10°)

#### Frame 0.1s: Wind-up
- Hips down max (BoneHips: Y+10)
- Legs bent max (BoneLowerLegL/R: -50°)
- Arms back max (BoneUpperArmR/L: 40°)

#### Frame 0.2s: Launch
- Hips up (BoneHips: Y-5)
- Legs extending (BoneLowerLegL/R: -10°)
- Arms forward (BoneUpperArmL/R: -45°)
- Chest back (BoneChest: -5°)

**Transition:** → `jump_airborne`

---

### Animation 2: Jump Airborne

**Duration:** 0.5s (Loop: On)

**Keyframes:**

#### Frame 0.0s: Peak
- Hips neutral (Y+0)
- Legs slightly bent (BoneLowerLegL/R: -20°)
- Arms raised (BoneUpperArmL/R: -80°)
- Chest back (BoneChest: -10°)
- Head looking up (BoneHead: -5°)

#### Frame 0.25s: Tuck
- Legs pull up (BoneUpperLegL/R: -30°, BoneLowerLegL/R: -60°)
- Arms neutral (BoneUpperArmL/R: -45°)

#### Frame 0.5s: Peak (Loop)
- Zurück zu Frame 0.0s

**Transition:** When grounded → `jump_landing`

---

### Animation 3: Jump Landing

**Duration:** 0.3s (kein Loop)

**Keyframes:**

#### Frame 0.0s: Impact
- Hips down (BoneHips: Y+12)
- Legs bent (BoneLowerLegL/R: -60°)
- Arms out (BoneUpperArmL/R: 20°, spread for balance)
- Chest forward (BoneChest: 15°)

#### Frame 0.15s: Absorb
- Hips down max (BoneHips: Y+15)
- Legs bent max (BoneLowerLegL/R: -65°)

#### Frame 0.3s: Recover
- Hips normal (BoneHips: Y+0)
- Legs straighten (BoneLowerLegL/R: -5°)
- Arms back to idle (BoneUpperArmL/R: 0°)
- Chest normal (BoneChest: 0°)

**Transition:** → `idle`

---

### Deliverables Phase 5
- ✅ Jump Startup Animation (crouch → launch)
- ✅ Jump Airborne Animation (looping mid-air)
- ✅ Jump Landing Animation (impact → recover)
- ✅ Transitions zwischen Animationen sind smooth

---

## Phase 6: AnimationTree Setup (Tag 3 Vormittag)

### Ziel
Erstelle **AnimationTree** für State-basierte Animation-Blending.

### AnimationTree Structure

```
AnimationTree
└── RootNode (AnimationNodeStateMachine)
    ├── Idle (AnimationNodeAnimation)
    ├── Walk (AnimationNodeAnimation)
    ├── JumpStartup (AnimationNodeAnimation)
    ├── JumpAirborne (AnimationNodeAnimation)
    └── JumpLanding (AnimationNodeAnimation)
```

### State Transitions

```
Idle ⇄ Walk
  Condition: velocity.x != 0

Walk → JumpStartup
  Condition: is_jumping && is_on_floor

Idle → JumpStartup
  Condition: is_jumping && is_on_floor

JumpStartup → JumpAirborne
  Auto-advance after 0.2s

JumpAirborne → JumpLanding
  Condition: is_on_floor

JumpLanding → Idle
  Auto-advance after 0.3s

JumpLanding → Walk
  Condition: velocity.x != 0 (after landing)
```

### Script Integration

```gdscript
# caprica_avatar.gd
extends Node2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var velocity: Vector2 = Vector2.ZERO
var is_on_floor: bool = true
var is_jumping: bool = false

func _process(_delta: float) -> void:
	_update_animation_state()

func _update_animation_state() -> void:
	if is_jumping and is_on_floor:
		state_machine.travel("JumpStartup")
		is_jumping = false
	elif not is_on_floor:
		if state_machine.get_current_node() != "JumpAirborne":
			state_machine.travel("JumpAirborne")
	elif velocity.x != 0:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
```

### Deliverables Phase 6
- ✅ AnimationTree funktioniert
- ✅ State Transitions sind smooth (kein "popping")
- ✅ Script kann AnimationTree steuern

---

## Phase 7: Direction Flip & Z-Index Swap (Tag 3 Nachmittag)

### Ziel
Caprica kann nach **links/rechts schauen**, und Arm/Leg Z-Index wechselt korrekt.

### Flip Logic

**Methode:** Nicht `Sprite2D.flip_h` nutzen (zerstört Bone-Attachment)!

**Stattdessen:** `scale.x = -1` auf Root Node.

```gdscript
func set_direction(dir: int) -> void:
	if dir < 0:
		scale.x = -1  # Facing left
		_update_z_indices_for_left()
	else:
		scale.x = 1   # Facing right
		_update_z_indices_for_right()

func _update_z_indices_for_left() -> void:
	# Rechter Arm/Bein hinter Körper
	right_upper_arm_sprite.z_index = -1
	right_lower_arm_sprite.z_index = -1
	right_hand_sprite.z_index = -1
	right_upper_leg_sprite.z_index = -1
	right_lower_leg_sprite.z_index = -1
	right_foot_sprite.z_index = -1
	
	# Linker Arm/Bein vor Körper
	left_upper_arm_sprite.z_index = 1
	left_lower_arm_sprite.z_index = 1
	left_hand_sprite.z_index = 1
	left_upper_leg_sprite.z_index = 0
	left_lower_leg_sprite.z_index = 0
	left_foot_sprite.z_index = 0

func _update_z_indices_for_right() -> void:
	# Spiegele Logic
	pass
```

### Test
- Caprica läuft nach rechts → Rechter Arm vor Körper
- Caprica läuft nach links → Linker Arm vor Körper
- Keine clipping issues

### Deliverables Phase 7
- ✅ Direction Flip funktioniert
- ✅ Z-Index wechselt korrekt
- ✅ Keine visuellen Glitches

---

## Phase 8: Integration mit Player Scene (Tag 3 Abend)

### Ziel
Integriere **CapricaAvatar** in die bestehende Player-Scene.

### Current Player Scene

**Was existiert bereits:**
- `res/Scenes/player.tscn` (State Machine-basiert)
- Character Body + Collision Shape
- State Machine Logic (Idle, Move, Jump, etc.)

### Integration Steps

1. **CapricaAvatar als Child:**
   - `Player (CharacterBody2D)`
     - `CapricaAvatar (Node2D)` ← Neu!
     - `CollisionShape2D`
     - `StateMachine`

2. **Signals verbinden:**
   - State Machine → CapricaAvatar (für Animation-Triggers)

3. **Script Update:**
```gdscript
# player.gd
@onready var avatar: Node2D = $CapricaAvatar

func _physics_process(delta: float) -> void:
	# Existing movement code...
	
	# Update avatar direction
	if velocity.x != 0:
		avatar.set_direction(sign(velocity.x))
	
	# Update avatar animation flags
	avatar.is_on_floor = is_on_floor()
	avatar.velocity = velocity
```

### Test
- Player bewegt sich → Avatar animiert
- Player springt → Jump Animation spielt
- Player steht → Idle Animation spielt

### Deliverables Phase 8
- ✅ CapricaAvatar ist in Player Scene integriert
- ✅ Animationen reagieren auf Player Movement
- ✅ Keine Conflicts mit bestehender State Machine

---

## Definition of Done (DoD)

### Functional
- [ ] Caprica steht im Level und atmet (Idle Animation)
- [ ] Walk Cycle sieht natürlich aus
- [ ] Jump Sequence ist smooth (Startup → Airborne → Landing)
- [ ] Direction Flip funktioniert (Left/Right)
- [ ] Z-Index wechselt korrekt (keine clipping issues)

### Integration
- [ ] CapricaAvatar ist in `res/Scenes/player.tscn` integriert
- [ ] AnimationTree reagiert auf Player State
- [ ] Keine Errors in Console

### Quality
- [ ] Animationen sind smooth (kein "popping" oder "jittering")
- [ ] Bone-Rotationen sehen natürlich aus (keine "broken limbs")
- [ ] Performance ist okay (60 FPS auf Target-Hardware)

### Documentation
- [ ] Rig-Structure ist dokumentiert (Bone-Names, Hierarchy)
- [ ] Z-Index Rules sind klar
- [ ] Script-Integration ist kommentiert

---

## Nach Mercury-1: Was kommt als Nächstes?

**Mercury-2:** RockJay System (bereits dokumentiert)

**Mercury-3:** Platformer Movement Polish + Respawn Ritual

**Mercury-4:** Combat System (Kick/Punch Animations)

---

## Risiken & Mitigation

### Risiko 1: Bone-Attachment funktioniert nicht
**Problem:** Sprites folgen Bones nicht.  
**Mitigation:**
- Skeleton Path korrekt gesetzt?
- Bone Name exakt richtig geschrieben?
- Sprite Offset stimmt?

### Risiko 2: Z-Index Bugs
**Problem:** Arme/Beine clipping durch Körper.  
**Mitigation:**
- Z-Index Swap beim Flip implementieren
- Test mit Debug-Overlay (zeige Z-Index)

### Risiko 3: Animationen sehen "robotic" aus
**Problem:** Bewegungen sind zu steif.  
**Mitigation:**
- Easing Curves nutzen (Ease In/Out)
- Mehr Keyframes für smooth transitions
- Reference Videos anschauen (real walk cycles)

### Risiko 4: Performance Issues
**Problem:** Zu viele Sprites/Bones = Lag.  
**Mitigation:**
- Profiler nutzen (Godot Performance Monitor)
- Falls nötig: Body-Parts mergen (z.B. Torso + Midriff = eine Texture)

---

## Tools & References

### Godot Docs
- [Skeleton2D](https://docs.godotengine.org/en/stable/classes/class_skeleton2d.html)
- [Bone2D](https://docs.godotengine.org/en/stable/classes/class_bone2d.html)
- [AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html)

### External References
- **Walk Cycle Tutorial:** [Animator's Survival Kit - Richard Williams](https://www.youtube.com/watch?v=2iqk0I3vD5M)
- **Paperdoll Animation Examples:** Second Life Avatar Rigging (Jerome's Reference)

### Asset Tools
- **Placeholder Generator:** `create_placeholders.py` (bereits im Projekt)
- **Reference Image:** `CapricaPaperDoll.png`

---

## Notizen

- **Art Direction noch offen:** Finaler Look von Caprica (Outfit, Colors)
- **Head Rotation System:** Shader-basierte Parallax Head → verschoben nach `src/experiments/head_rotation/` (zu advanced für MVP)
- **Equipment System:** Paperdoll Equipment Swaps (später in Mercury-4+)

---

**Ende Mercury-1 Mission Plan**

---

## Changelog

- **01.01.2026 10:13** - Mission Plan erstellt (Celestine)
