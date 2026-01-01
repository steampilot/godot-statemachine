# Mercury Mission 2: RockJay System

**Status:** Geplant (Nach Mercury-1 Caprica Avatar)  
**Priorität:** Kritisch – Herz des Games  
**Geschätzte Dauer:** 4 Wochen  
**Abhängigkeiten:** Mercury-1 (Caprica Avatar/Animation)

---

## Mission Objective

Baue **RockJay** – das Musik-Mix-System, das gleichzeitig als:
- Main Menu dient
- Respawn-Screen fungiert
- Core Gameplay Loop ermöglicht
- Club-Gate-Lösung bietet
- Narrativen Anker darstellt

**Erfolgs-Kriterium:**  
Spieler kann ohne Vorkenntnisse einen Track mixen, der **immer gut klingt** (eJay No-Fail-Prinzip), auf "PRINT TO TAPE" drücken, und Caprica springt aus dem Fenster ins Level.

---

## Warum RockJay zuerst?

Weil **alles andere** darauf aufbaut:
- ✅ Main Menu = RockJay
- ✅ Respawn Ritual = Kassette in RockJay spulen
- ✅ Club Gate Lösung = Remix in RockJay
- ✅ Loot System = Samples für RockJay
- ✅ Progression = Unlocks in RockJay
- ✅ Story Beat = "Du hast es selbst gemacht"

**Wenn RockJay nicht funktioniert, funktioniert die Core Loop nicht.**

---

## Was NICHT in Mercury-2 ist

❌ Combat System (Mercury-3)  
❌ Platforming Movement (Mercury-1 + 3)  
❌ Kassetten-Loot (Mercury-3)  
❌ Story Cutscenes (Mercury-4)  
❌ Death/Respawn Animation (Mercury-3)  
❌ Steampilot NPC (Mercury-4)  
❌ Dämon Boss (Mercury-5+)

**Scope:** Nur RockJay GUI + Playback + "PRINT TO TAPE" → Fake Level Start.

---

## Phase 1: Grid System (Woche 1)

### Ziel
Erstelle das **Grid-Layout**, in das Samples gedroppt werden können.

### Requirements

#### Visual Layout
```
┌─────────────────────────────────────────────────┐
│ RockJay v1.0                        [X]         │
├─────────────────────────────────────────────────┤
│ DRUMS   │ ████░░░░│ ░░░░████│ ████████│ ░░░░░░░░│
│ BASS    │ ████████│ ████████│ ████████│ ████████│
│ LEAD    │ ░░░░████│ ████░░░░│ ░░░░████│ ████░░░░│
│ SHOUT   │ ████░░░░│ ░░░░░░░░│ ████░░░░│ ░░░░░░░░│
├─────────────────────────────────────────────────┤
│           Bar 1     Bar 2     Bar 3     Bar 4   │
└─────────────────────────────────────────────────┘
```

#### Technische Specs
- **4 Tracks (Spuren):** DRUMS, BASS, LEAD, SHOUT
- **4 Bars (Takte):** Loop-Length = 4 Bars
- **Grid Cells:** 4 Tracks x 4 Bars = 16 Slots
- **Cell Size:** 100x60px (anpassbar je nach UI-Scale)
- **Visual States:**
  - Leer: Dunkelgrau, Outline
  - Befüllt: Icon + Farbe (je nach Sample-Kategorie)
  - Hover: Highlight (wenn Drag über Slot)

#### Scene Structure
```
RockJayMenu (Control)
├── Background (TextureRect)
│   └── Texture: res://Assets/Graphics/rockjay_bg.png
├── GridContainer (VBoxContainer)
│   ├── TrackRow_Drums (HBoxContainer)
│   │   ├── TrackLabel (Label: "DRUMS")
│   │   ├── BarSlot_0 (Panel) [Drag Target]
│   │   ├── BarSlot_1 (Panel) [Drag Target]
│   │   ├── BarSlot_2 (Panel) [Drag Target]
│   │   ├── BarSlot_3 (Panel) [Drag Target]
│   ├── TrackRow_Bass (HBoxContainer)
│   │   └── ... (gleiche Struktur)
│   ├── TrackRow_Lead (HBoxContainer)
│   │   └── ...
│   ├── TrackRow_Shout (HBoxContainer)
│   │   └── ...
```

#### Script: `bar_slot.gd`
```gdscript
extends Panel

signal sample_dropped(sample_id: String, bar_index: int, track_id: String)
signal sample_removed(bar_index: int, track_id: String)

@export var bar_index: int = 0
@export var track_id: String = ""

var current_sample_id: String = ""
var current_sample_icon: Texture2D = null

func _ready() -> void:
	_update_visual()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("sample_id")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	current_sample_id = data["sample_id"]
	current_sample_icon = data.get("icon", null)
	sample_dropped.emit(current_sample_id, bar_index, track_id)
	_update_visual()

func clear_sample() -> void:
	current_sample_id = ""
	current_sample_icon = null
	sample_removed.emit(bar_index, track_id)
	_update_visual()

func _update_visual() -> void:
	if current_sample_id != "":
		modulate = Color.GREEN
		# TODO: Show icon if available
	else:
		modulate = Color.DARK_GRAY

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_sample()
```

#### Deliverables Phase 1
- ✅ Grid-Layout funktioniert (visuell)
- ✅ Slots sind als Drag-Targets erkennbar
- ✅ Right-Click entfernt Sample
- ✅ Visual Feedback (leer/befüllt)

---

## Phase 2: Sample Library (Woche 1-2)

### Ziel
Erstelle die **Sample Buckets**, aus denen Samples ins Grid gezogen werden.

### Requirements

#### Visual Layout
```
┌────────────────────────────────┐
│ SAMPLE LIBRARY                 │
├────────────────────────────────┤
│ DRUMS                          │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
│ │ 01 │ │ 02 │ │ 03 │ │ 04 │  │
│ └────┘ └────┘ └────┘ └────┘  │
├────────────────────────────────┤
│ BASS                           │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
│ │ 01 │ │ 02 │ │ 03 │ │ 04 │  │
│ └────┘ └────┘ └────┘ └────┘  │
└────────────────────────────────┘
```

#### Technische Specs
- **4 Kategorien:** DRUMS, BASS, LEAD, SHOUT
- **4 Samples pro Kategorie** (MVP)
- **Locked/Unlocked State:**
  - Unlocked: Farbig, draggable
  - Locked: Grau, nicht draggable, Tooltip: "Find in Level 1"
- **Drag Preview:** Halb-transparente Kopie des Icons

#### Scene Structure
```
SampleLibrary (VBoxContainer)
├── CategoryDrums (VBoxContainer)
│   ├── CategoryLabel (Label: "DRUMS")
│   ├── SampleGrid (HBoxContainer)
│   │   ├── SampleBucket_01 (TextureButton) [Drag Source]
│   │   ├── SampleBucket_02 (TextureButton)
│   │   ├── SampleBucket_03 (TextureButton)
│   │   ├── SampleBucket_04 (TextureButton)
├── CategoryBass (VBoxContainer)
│   └── ... (gleiche Struktur)
```

#### Script: `sample_bucket.gd`
```gdscript
extends TextureButton

@export var sample_id: String = ""
@export var sample_audio: AudioStream
@export var is_unlocked: bool = true
@export var icon: Texture2D

func _ready() -> void:
	texture_normal = icon
	_update_locked_state()

func _update_locked_state() -> void:
	if not is_unlocked:
		modulate = Color(0.3, 0.3, 0.3)
		disabled = true
		tooltip_text = "Locked: Find in Level"
	else:
		modulate = Color.WHITE
		disabled = false
		tooltip_text = sample_id

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not is_unlocked:
		return null
	
	var preview = TextureRect.new()
	preview.texture = icon
	preview.modulate = Color(1, 1, 1, 0.5)
	preview.size = Vector2(64, 64)
	set_drag_preview(preview)
	
	return {
		"sample_id": sample_id,
		"audio": sample_audio,
		"icon": icon
	}
```

#### Deliverables Phase 2
- ✅ Sample Library UI funktioniert
- ✅ Drag & Drop von Samples ins Grid
- ✅ Locked/Unlocked Samples (visuell unterscheidbar)
- ✅ Drag Preview sichtbar

---

## Phase 3: Audio Playback (Woche 2)

### Ziel
Implementiere **Audio Playback**: Spieler drückt PLAY, alle platzierten Samples spielen synchron ab.

### Requirements

#### eJay No-Fail Formula
Damit Musik **immer** gut klingt:
1. **Alle Samples: 140 BPM**
2. **Alle Samples: E Minor (oder eine andere Tonart)**
3. **Alle Samples: 4 Bars lang** (oder 2 Bars, aber konsistent)
4. **Quantisiert:** Samples starten nur auf Bar-Start
5. **Kein Reverb-Tail über Bar-Ende hinaus**

#### Playback Logic
- **Play Button:** Startet Loop (4 Bars)
- **Stop Button:** Stoppt alle Tracks
- **Loop Mode:** Nach Bar 4 → zurück zu Bar 1
- **Sync:** Alle Tracks starten gleichzeitig (kein Desync)

#### Scene Structure
```
AudioPlayers (Node)
├── AudioStreamPlayer_Drums
├── AudioStreamPlayer_Bass
├── AudioStreamPlayer_Lead
├── AudioStreamPlayer_Shout
```

#### Script: `rockjay_menu.gd`
```gdscript
extends Control

@onready var play_button: Button = $Controls/PlayButton
@onready var stop_button: Button = $Controls/StopButton
@onready var print_button: Button = $Controls/PrintToTapeButton

@onready var audio_drums: AudioStreamPlayer = $AudioPlayers/Drums
@onready var audio_bass: AudioStreamPlayer = $AudioPlayers/Bass
@onready var audio_lead: AudioStreamPlayer = $AudioPlayers/Lead
@onready var audio_shout: AudioStreamPlayer = $AudioPlayers/Shout

var active_tracks: Dictionary = {
	"drums": ["", "", "", ""],
	"bass": ["", "", "", ""],
	"lead": ["", "", "", ""],
	"shout": ["", "", "", ""]
}

const BAR_DURATION: float = 2.0  # 140 BPM = 2 seconds per bar
var is_playing: bool = false
var current_bar: int = 0

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	print_button.pressed.connect(_on_print_pressed)

func _on_play_pressed() -> void:
	if is_playing:
		return
	is_playing = true
	current_bar = 0
	_play_loop()

func _on_stop_pressed() -> void:
	is_playing = false
	audio_drums.stop()
	audio_bass.stop()
	audio_lead.stop()
	audio_shout.stop()

func _play_loop() -> void:
	while is_playing:
		_play_bar(current_bar)
		await get_tree().create_timer(BAR_DURATION).timeout
		current_bar = (current_bar + 1) % 4

func _play_bar(bar_index: int) -> void:
	_play_track_sample("drums", audio_drums, bar_index)
	_play_track_sample("bass", audio_bass, bar_index)
	_play_track_sample("lead", audio_lead, bar_index)
	_play_track_sample("shout", audio_shout, bar_index)

func _play_track_sample(track_id: String, player: AudioStreamPlayer, bar_index: int) -> void:
	var sample_id = active_tracks[track_id][bar_index]
	if sample_id == "":
		return
	
	var sample_audio = _get_sample_audio(sample_id)
	if sample_audio:
		player.stream = sample_audio
		player.play()

func _get_sample_audio(sample_id: String) -> AudioStream:
	# TODO: Load from SampleRegistry
	return null

func _on_sample_dropped(sample_id: String, bar_index: int, track_id: String) -> void:
	active_tracks[track_id][bar_index] = sample_id

func _on_sample_removed(bar_index: int, track_id: String) -> void:
	active_tracks[track_id][bar_index] = ""
```

#### Deliverables Phase 3
- ✅ PLAY Button startet Playback
- ✅ STOP Button stoppt Playback
- ✅ Loop funktioniert (4 Bars repeat)
- ✅ Alle Tracks spielen synchron

---

## Phase 4: PRINT TO TAPE (Woche 3)

### Ziel
Implementiere den **"PRINT TO TAPE" Button** und die Transition ins Spiel.

### Requirements

#### Flow
1. Spieler drückt "PRINT TO TAPE"
2. Animation: Kassette eject (smack-pack Sound)
3. Caprica Sprite: nimmt Kassette (Hand-Animation)
4. Caprica: steckt Kassette in Walkman (Click Sound)
5. Caprica: zieht Earbuds rein (Cable Sound)
6. Fade to Black
7. Caprica: springt aus Fenster (Cutscene/Animation)
8. Level 1 startet (Placeholder: "Level coming soon")

#### Scene Structure
```
TransitionScene (Control)
├── AnimationPlayer
│   └── Animation: "eject_tape"
│       ├── Track: CassetteSprite (position, rotation)
│       ├── Track: CapricaSprite (animation frame)
│       ├── Track: AudioPlayer (smack, click, cable)
├── CassetteSprite (Sprite2D)
├── CapricaSprite (Sprite2D)
├── AudioPlayer (AudioStreamPlayer)
```

#### Script: `transition_manager.gd`
```gdscript
extends Control

signal transition_complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cassette_sprite: Sprite2D = $CassetteSprite
@onready var caprica_sprite: Sprite2D = $CapricaSprite

func play_print_to_tape_animation() -> void:
	animation_player.play("eject_tape")
	await animation_player.animation_finished
	transition_complete.emit()
```

#### Deliverables Phase 4
- ✅ "PRINT TO TAPE" Button funktioniert
- ✅ Kassette Eject Animation (kann Placeholder sein)
- ✅ Sound Effects (smack, click, cable)
- ✅ Fade to Black → Placeholder Level Screen

---

## Audio Assets (MVP Requirements)

### Sample Inventory (16 Samples)

#### DRUMS (4 Samples)
- `drums_01_kick.wav` (4 Bars, 140 BPM, E Minor)
- `drums_02_snare.wav`
- `drums_03_hihat.wav`
- `drums_04_full_kit.wav`

#### BASS (4 Samples)
- `bass_01_deep.wav`
- `bass_02_funky.wav`
- `bass_03_synth.wav`
- `bass_04_distorted.wav`

#### LEAD (4 Samples)
- `lead_01_guitar.wav`
- `lead_02_synth.wav`
- `lead_03_piano.wav`
- `lead_04_vocal_melody.wav`

#### SHOUT (4 Samples)
- `shout_01_hey.wav`
- `shout_02_yeah.wav`
- `shout_03_woo.wav`
- `shout_04_scream.wav`

### Format Specs
- **Format:** WAV, 44.1kHz, 16-bit, Stereo
- **Length:** 8 seconds (4 Bars @ 140 BPM)
- **Key:** E Minor (oder eine andere, aber konsistent)
- **BPM:** 140 (locked)
- **Normalization:** Peak -3dB (kein Clipping)

### Sample Registry
```gdscript
# sample_registry.gd (Autoload)
extends Node

const SAMPLES: Dictionary = {
	"drums_01": preload("res://Assets/Audio/Samples/drums_01_kick.wav"),
	"drums_02": preload("res://Assets/Audio/Samples/drums_02_snare.wav"),
	# ... etc
}

func get_sample(sample_id: String) -> AudioStream:
	return SAMPLES.get(sample_id, null)
```

---

## UI/UX Polish (Woche 4)

### Ziel
Mache RockJay **juicy** und intuitiv.

### Features

#### Visual Feedback
- **Drag Highlight:** Slot leuchtet grün, wenn Drag darüber ist
- **Drop Animation:** Sample "poppt" in Slot (scale bounce)
- **Play Indicator:** Aktueller Bar leuchtet während Playback
- **Sample Icons:** Jedes Sample hat erkennbares Icon

#### Sound Effects
- **Drag Start:** Kleines "Pick Up" Sound
- **Drop:** "Snap" Sound (Magnet-Effekt)
- **Remove:** "Pop" Sound
- **Play Start:** "Tape Start" Sound (mechanical)
- **Print to Tape:** "SMACK" Sound (ikonisch!)

#### Tooltips
- **Sample Bucket:** Zeigt Sample-Name + "Drag to Grid"
- **Locked Sample:** "Locked: Find in Level X"
- **Empty Slot:** "Drop sample here"

#### Keyboard Shortcuts
- **Space:** Play/Stop Toggle
- **P:** Print to Tape
- **Ctrl+Z:** Undo last sample placement
- **Escape:** Clear all samples

---

## Testing Checklist

### Funktional
- [ ] Samples können ins Grid gezogen werden
- [ ] Right-Click entfernt Sample
- [ ] PLAY Button startet Playback
- [ ] STOP Button stoppt Playback
- [ ] Loop funktioniert (4 Bars, dann wieder Bar 1)
- [ ] Alle Tracks spielen synchron (kein Desync)
- [ ] PRINT TO TAPE startet Transition
- [ ] Locked Samples sind nicht draggable

### Performance
- [ ] Kein Audio-Lag beim Playback
- [ ] Drag & Drop ist responsiv (< 16ms Frame Time)
- [ ] Keine Memory Leaks (Samples werden nicht dupliziert)

### UX
- [ ] Spieler versteht Drag & Drop ohne Tutorial
- [ ] Musik klingt immer gut (No-Fail-Prinzip)
- [ ] Feedback ist klar (visuell + audio)
- [ ] Transition ist nicht verwirrend

---

## Integration mit Core Game Loop

### Nach Mercury-2: Was passiert als Nächstes?

#### Mercury-3: Platformer Core
- Caprica kann sich bewegen (Jump, Dash, Climb)
- Kassetten als Loot im Level
- Respawn-Ritual (Bleistift-Rewind)
- Zurück zu RockJay nach Tod

#### Mercury-4: Club Gate
- Club-NPC (Steampilot)
- Kassette geklaut → Boss Fight
- Kassette fällt ins Wasser
- Remix in RockJay löst Gate

#### Mercury-5+: Progression
- Neue Samples unlocked via Loot
- RockJay Library wächst
- Mehr Tracks, mehr Bars
- Advanced Features (FX, Tempo, Pitch)

---

## Risiken & Mitigation

### Risiko 1: Audio Sync Probleme
**Problem:** Tracks laufen auseinander (Desync).  
**Mitigation:**
- Alle Samples exakt gleiche Länge
- Nutze `AudioServer.get_time_since_last_mix()` für präzises Timing
- Test mit Metronom (click track)

### Risiko 2: Samples klingen nicht gut zusammen
**Problem:** Spieler mixed Samples, die harmonisch nicht passen.  
**Mitigation:**
- Alle Samples in gleicher Tonart
- Pre-Test: Alle Sample-Kombinationen durchhören
- Falls nötig: Samples nachbearbeiten

### Risiko 3: UI ist nicht intuitiv
**Problem:** Spieler versteht Drag & Drop nicht.  
**Mitigation:**
- Erstes Mal: Interaktives Tutorial (Hand-Icon zeigt Drag)
- Tooltips überall
- Playtest mit unbiased Testern

### Risiko 4: Transition wirkt abrupt
**Problem:** "PRINT TO TAPE" → Level Start fühlt sich disconnected an.  
**Mitigation:**
- Smooth Fade Out
- Sound Bridge (Musik läuft leise weiter während Transition)
- Cutscene mit Caprica (visueller Kontext)

---

## Erfolgskriterien (Done = ✅)

- [ ] Spieler kann ohne Anleitung Samples ins Grid ziehen
- [ ] Musik klingt immer gut (mindestens 50% der Kombinationen "funktionieren")
- [ ] PLAY/STOP funktioniert ohne Bugs
- [ ] PRINT TO TAPE führt zu Level (oder Placeholder)
- [ ] Respawn-Ritual nutzt RockJay (Bleistift-Rewind)
- [ ] Locked Samples sind visuell klar
- [ ] Kein Audio-Lag/Desync
- [ ] UI ist responsive (< 16ms Frame Time)

---

## Nächster Schritt nach Mission-2

**Mercury-3:** Platformer Core + Death/Respawn Ritual

**Dependency Chain:**
1. Mercury-1: Caprica Avatar ✅ (aktuell in Arbeit)
2. Mercury-2: RockJay System (dieses Dokument)
3. Mercury-3: Platformer + Respawn (nutzt RockJay)
4. Mercury-4: Club Gate + Steampilot NPC
5. Mercury-5+: Combat + Endgame

---

## Anmerkungen

- **Art Direction:** RockJay Look noch nicht final (retro PC? Dark modern?)
- **Sample Source:** Externe Library? Selbst produziert? KI-generiert?
- **Icon Design:** Brauchen wir einen Icon-Artist? Oder Placeholder-Shapes?
- **Cutscene-Qualität:** Sprite Animation? Rendered Video? Static Frames?

**TODO:** Nach Mercury-1 besprechen.

---

## Referenzen

- **eJay Series:** No-Fail Music Maker (1997-2003)
- **Mario Paint Composer:** Grid-Based Music
- **Incredibox:** Drag & Drop Loops
- **GarageBand:** Track-Based Mixing (vereinfacht)

---

**Ende Mercury-2 Mission Plan**
