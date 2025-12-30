# HOME STUDIO SYSTEM

## Überblick

Das **Home Studio System** ist eine Post-Game Creative Experience, die es Spielern ermöglicht, den Boss-Song in seine Komponenten zu zerlegen und einen eigenen "Remix" zu erstellen. Dies ist ein Empowerment-Moment—der Spieler wird vom Konsumenten zum Schöpfer.

Nach dem Besiegen des Boss erhält Caprica einen magischen Musikstudio-Raum, wo sie das 4-Track Arrangement des Boss-Songs remixen kann. Das Spiel nutzt Music Maker–Paradigma: Drag-Drop Samples auf einem Grid, um verschiedene Instrumentenkombinationen zu erstellen.

**Ziel:** "Mama, ich bin Musikerin!"—der emotionale Höhepunkt, der zeigt, dass Musik Macht ist.

---

## Kern-Konzept: 4-Sample-System

### Samples des Boss-Songs
Der Boss-Track wird in vier isolierte Stems zerlegt:

1. **Drum Track** – Percussion, Beat Foundation
2. **Bass Track** – Low-End, Groove-Element
3. **Guitar Track** – Melodie, Harmonie, Charakter
4. **Vocal Track** – Boss-Stimme, Atmosphere, Drama

Jedes Sample:
- Ist *in sich perfekt loopbar* (Takt-synchron)
- Erzeugt harmonische Grundlagen
- Kann ein- und ausgeschaltet werden
- Hat visuelle Darstellung (Waveform oder abstract Block)

### Grid-basierte Arrangement
Das UI präsentiert ein Timeline-Grid (Music Maker Stil):

```
DRUM   [X] [X] [ ] [X] [X] [ ] [X] [X]
BASS   [X] [X] [X] [X] [X] [X] [X] [X]
GUITAR [ ] [ ] [X] [ ] [X] [X] [ ] [X]
VOCAL  [ ] [X] [ ] [X] [ ] [ ] [X] [ ]
       [1] [2] [3] [4] [5] [6] [7] [8]
```

- **Jede Zelle = 1 Takt (beat)**
- **Jede Reihe = 1 Sample/Instrument**
- **Spieler klickt auf Zellen**, um sie an/aus zu schalten
- **Echtzeit-Feedback**: Audio spielt sofort, wenn Arrangement ändert sich
- **Loop: 8 Takte** (oder länger für Erweiterung)

---

## Implementierungs-Details

### Audio-System Integration

```gdscript
# res/Globals/HOME_STUDIO.gd
extends Node

class_name HomeStudio

# Reference to boss song stems
@export var drum_stem: AudioStream
@export var bass_stem: AudioStream
@export var guitar_stem: AudioStream
@export var vocal_stem: AudioStream

# Grid state: [track_index][beat_index] -> bool
var grid_state: Array[Array] = [
    [true, true, false, true, true, false, true, true],  # drums
    [true, true, true, true, true, true, true, true],    # bass
    [false, false, true, false, true, true, false, true], # guitar
    [false, true, false, true, false, false, true, false] # vocal
]

var current_beat: int = 0
var is_playing: bool = false
var bpm: float = 120.0
var beat_duration: float = 60.0 / bpm  # seconds per beat

# Audio players (one per stem)
var audio_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
    # Initialize audio players for each stem
    audio_players = [
        AudioStreamPlayer.new(),  # drums
        AudioStreamPlayer.new(),  # bass
        AudioStreamPlayer.new(),  # guitar
        AudioStreamPlayer.new()   # vocal
    ]

    # Assign stems to players
    var stems = [drum_stem, bass_stem, guitar_stem, vocal_stem]
    for i in range(audio_players.size()):
        audio_players[i].stream = stems[i]
        audio_players[i].bus = "Music"
        add_child(audio_players[i])

func play_grid() -> void:
    # Start playback of current grid arrangement
    is_playing = true
    current_beat = 0

    # Stop all players and restart
    for player in audio_players:
        player.stop()
        player.seek(0.0)

    _on_beat_tick()

func stop_grid() -> void:
    is_playing = false
    for player in audio_players:
        player.stop()

func _process(delta: float) -> void:
    if not is_playing:
        return

    # Advance to next beat at BPM interval
    # (Simplified; real implementation uses precise timing)
    pass

func toggle_cell(track_idx: int, beat_idx: int) -> void:
    # User clicked on grid cell
    if track_idx >= 0 and track_idx < grid_state.size():
        if beat_idx >= 0 and beat_idx < grid_state[track_idx].size():
            grid_state[track_idx][beat_idx] = not grid_state[track_idx][beat_idx]
            _update_audio_playback()

func _update_audio_playback() -> void:
    # Sync audio players based on grid_state
    # At each beat, check if this track's cell is active
    var current_cell_active = grid_state[current_beat] if current_beat < grid_state.size() else []

    for track_idx in range(audio_players.size()):
        if track_idx < current_cell_active.size() and current_cell_active[track_idx]:
            if not audio_players[track_idx].playing:
                audio_players[track_idx].play()
        else:
            audio_players[track_idx].stop()
```

### UI-Komponente

Die Home Studio UI nutzt ein `GridContainer` mit Toggle-Buttons:

```gdscript
# res/Scenes/HomeStudioUI.gd
extends Control

class_name HomeStudioUI

@onready var grid_container: GridContainer = $GridContainer
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var stop_button: Button = $VBoxContainer/StopButton
@onready var save_button: Button = $VBoxContainer/SaveButton

const GRID_ROWS: int = 4  # drums, bass, guitar, vocal
const GRID_COLS: int = 8  # 8 beats per loop
const CELL_SIZE: Vector2 = Vector2(64, 64)

var home_studio: HomeStudio
var cell_buttons: Array[Array] = []

func _ready() -> void:
    home_studio = get_node("/root/Main/HomeStudio")  # Adjust path as needed
    _create_grid_buttons()

    play_button.pressed.connect(home_studio.play_grid)
    stop_button.pressed.connect(home_studio.stop_grid)
    save_button.pressed.connect(_save_remix)

func _create_grid_buttons() -> void:
    grid_container.columns = GRID_COLS

    for track_idx in range(GRID_ROWS):
        var row: Array = []
        for beat_idx in range(GRID_COLS):
            var button = Button.new()
            button.custom_minimum_size = CELL_SIZE
            button.toggle_mode = true
            button.pressed.connect(func(): home_studio.toggle_cell(track_idx, beat_idx))

            # Set initial state from home_studio.grid_state
            if track_idx < home_studio.grid_state.size():
                if beat_idx < home_studio.grid_state[track_idx].size():
                    button.button_pressed = home_studio.grid_state[track_idx][beat_idx]

            grid_container.add_child(button)
            row.append(button)

        cell_buttons.append(row)

func _save_remix() -> void:
    # Save the current grid_state to player profile/global
    # Format: JSON or custom binary format
    var remix_data = {
        "grid_state": home_studio.grid_state,
        "bpm": home_studio.bpm,
        "timestamp": Time.get_ticks_msec()
    }

    var save_path = "user://remixes/remix_%d.json" % Time.get_ticks_msec()
    var json = JSON.stringify(remix_data)

    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_string(json)
```

---

## Best Practices

### Sample-Qualität & Timing
- **Jedes Sample muss Takt-synchron sein** (kein Latenz-Fehler zwischen Stems)
- **Fade-In/-Out bei Sample-Grenzen** verhindert Clicks beim Toggle
- **Loop-Punkte präzise setzen** (Audacity, DAW)
- **Test mit verschiedenen BPMs** um sicherzustellen, dass Timing robust bleibt

### UI/UX Feedback
- **Visuelles Feedback**: Toggle-Button ändert Farbe/Icon sofort
- **Audio Feedback**: Sample startet/stoppt sofort beim Click
- **Blink-Animation bei aktiven Cells** zeigt, welche Samples gerade spielen
- **Beat-Counter Display**: Zeigt aktuellen Beat im Grid (1-8)

### Performance
- **Audio-Streams vorab laden** (nicht streaming)
- **Stems als `.ogg` oder `.wav`** (Godot-native Formate)
- **Avoid Excessive State Updates**—nur bei tatsächlicher Änderung aktualisieren

---

## Integration mit anderen Systemen

### Mit Kampf-System
Nach Boss-Sieg:
1. **Boss besiegt** → `BossDefeated` Signal
2. **FadeOut zu Boss-Arena**
3. **FadeIn zu Home Studio**
4. **Home Studio Auto-startet mit Boss-Song Stems** (4-Track Loop)

```gdscript
# In BossBattle scene
boss.defeated.connect(func():
    MusicPlayer.fade_out(0.5)
    await get_tree().create_timer(0.5).timeout
    LevelLoader.load_scene("res://Scenes/HomeStudio.tscn")
)
```

### Mit Save-System
- **Remix-State speichern** in Player Profile
- **Multiple Remixes** erlaubt (verschiedene Grid-Konfigurationen)
- **Load Previous Remix** Option im UI

### Mit Audio-Bus
Home Studio nutzt dedizierten Bus:
```
Music
├─ Boss Song Stems (drums, bass, guitar, vocal)
└─ UI Feedback SFX (click, toggle)
```

---

## Testing & Validation

### Functional Tests
- [ ] Grid Toggle funktioniert (Cell an/aus)
- [ ] Audio synkronisiert sich mit Grid-State
- [ ] Play/Stop-Buttons funktionieren
- [ ] Remix speichern & laden funktioniert
- [ ] Multiple Remixes können nebeneinander existieren

### Quality Tests
- [ ] Audio-Timing: Stems sind synchron (keine Latenz zwischen Tracks)
- [ ] UI Response: Weniger als 50ms Latenz zwischen Click und Audio-Änderung
- [ ] Performance: CPU-Last bleibt unter 20% (4 parallele AudioStreamPlayers)
- [ ] Save-Format: JSON lesbar und robust gegen Korruption

### Edge Cases
- [ ] Was passiert wenn alle Samples disabled sind? → Stille, kein Fehler
- [ ] Was wenn BPM geändert wird mid-playback? → Seamless Transition
- [ ] Was wenn Save-Datei beschädigt ist? → Graceful Fallback zu Default Grid

### Spieler-Experience Test
- [ ] Aha-Moment: Spieler versteht sofort, dass sie remixen können
- [ ] Empowerment: "Ich hab das gemacht!" Gefühl
- [ ] Replayability: Wollen sie mehrere Remixes erstellen?

---

## Erweiterungsmöglichkeiten

### Phase 2: Extended Features
- **Mehr als 8 Beats**: 16 oder 32 Takte Loop
- **Sample-Längen ändern**: Nicht nur Ein/Aus, sondern Länge und Start-Point anpassen
- **Effekte hinzufügen**: Reverb, Delay auf einzelne Stems
- **Export-Funktion**: Remix als Audio-Datei exportieren für Social Media
- **Sharing**: Remixes online teilen und Bewertung erhalten

### Phase 3: Gameplay-Integration
- **Remix im Spiel nutzen**: Nächster Level spielt mit Caprica's Custom-Mix ab
- **Boss reagiert auf Remix**: Wenn Spieler aggressive Drums wählt, Boss wird aggressiver
- **Achievement**: "Erste Remix erstellt", "5 verschiedene Remixes", etc.

---

## Fazit

Das Home Studio System transformiert CapricaGame von reinem Action-Spiel zu einer **Kreativ-Plattform**. Es belohnt Spieler nicht nur mit Story-Fortschritt, sondern mit dem Gefühl, selbst Musik zu schaffen. Dies verstärkt das **Kernthema: Musik ist Magie**—und der Spieler ist jetzt Teil dieser Magie.
