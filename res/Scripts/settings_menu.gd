## res://Scripts/settings_menu.gd
extends Control

# UI References
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var dialog_slider: HSlider = %DialogSlider

@onready var master_label: Label = %MasterValueLabel
@onready var music_label: Label = %MusicValueLabel
@onready var sfx_label: Label = %SFXValueLabel
@onready var dialog_label: Label = %DialogValueLabel

@onready var back_button: Button = %BackButton

# Music Selection Radio Buttons
@onready var music_track1: CheckBox = %MusicTrack1
@onready var music_track2: CheckBox = %MusicTrack2
@onready var music_track3: CheckBox = %MusicTrack3

func _ready() -> void:
	print("✓ Settings Menu geladen")

	# Slider Setup
	_setup_slider(master_slider, 0.0, 1.0, 0.01)
	_setup_slider(music_slider, 0.0, 1.0, 0.01)
	_setup_slider(sfx_slider, 0.0, 1.0, 0.01)
	_setup_slider(dialog_slider, 0.0, 1.0, 0.01)

	# Load current values from AUDIO singleton
	_load_audio_settings()

	# Connect signals
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	dialog_slider.value_changed.connect(_on_dialog_changed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Music selection radio buttons
	music_track1.toggled.connect(_on_music_track1_toggled)
	music_track2.toggled.connect(_on_music_track2_toggled)
	music_track3.toggled.connect(_on_music_track3_toggled)

func _setup_slider(slider: HSlider, min_val: float, max_val: float, step: float) -> void:
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = step

func _load_audio_settings() -> void:
	if not Audio:
		return

	master_slider.value = Audio.get_master_volume()
	music_slider.value = Audio.get_music_volume()
	sfx_slider.value = Audio.get_sfx_volume()
	dialog_slider.value = Audio.get_dialog_volume()
	
	# Load current music track selection
	var current_track = Audio.get_music_track()
	music_track1.button_pressed = (current_track == 1)
	music_track2.button_pressed = (current_track == 2)
	music_track3.button_pressed = (current_track == 3)

	_update_labels()

func _update_labels() -> void:
	master_label.text = "%d%%" % int(master_slider.value * 100)
	music_label.text = "%d%%" % int(music_slider.value * 100)
	sfx_label.text = "%d%%" % int(sfx_slider.value * 100)
	dialog_label.text = "%d%%" % int(dialog_slider.value * 100)

func _on_master_changed(value: float) -> void:
	Audio.set_master_volume(value)
	master_label.text = "%d%%" % int(value * 100)

func _on_music_changed(value: float) -> void:
	Audio.set_music_volume(value)
	music_label.text = "%d%%" % int(value * 100)

func _on_sfx_changed(value: float) -> void:
	Audio.set_sfx_volume(value)
	sfx_label.text = "%d%%" % int(value * 100)

func _on_dialog_changed(value: float) -> void:
	Audio.set_dialog_volume(value)
	dialog_label.text = "%d%%" % int(value * 100)

func _on_back_pressed() -> void:
	print("→ Zurück zum Main Menu")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_music_track1_toggled(pressed: bool) -> void:
	if pressed:
		_select_music_track(1)

func _on_music_track2_toggled(pressed: bool) -> void:
	if pressed:
		_select_music_track(2)

func _on_music_track3_toggled(pressed: bool) -> void:
	if pressed:
		_select_music_track(3)

func _select_music_track(track_number: int) -> void:
	# Uncheck all other radio buttons
	music_track1.button_pressed = (track_number == 1)
	music_track2.button_pressed = (track_number == 2)
	music_track3.button_pressed = (track_number == 3)
	
	# Use global music manager
	Audio.set_music_track(track_number)
