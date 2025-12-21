## res://Scripts/main_menu.gd
extends Control

@onready var start_button: Button = %StartNewGame
@onready var load_button: Button = %LoadGame
@onready var settings_button: Button = %Settings
@onready var credits_button: Button = %Credits
@onready var exit_button: Button = %EndGame
@onready var quit_dialog: ConfirmationDialog = %QuitConfirmationDialog

func _ready() -> void:
	print("✓ Main Menu geladen")

	# Button Connections
	start_button.pressed.connect(_on_start_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# Dialog Connections
	quit_dialog.confirmed.connect(_on_quit_confirmed)

func _on_start_pressed() -> void:
	print("→ Neues Spiel wird geladen...")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_load_pressed() -> void:
	print("→ Load Game [NICHT IMPLEMENTIERT]")
	# TODO: Savegame-System implementieren

func _on_settings_pressed() -> void:
	print("→ Settings wird geladen...")
	get_tree().change_scene_to_file("res://Scenes/settings_menu.tscn")

func _on_credits_pressed() -> void:
	print("→ Credits [NICHT IMPLEMENTIERT]")
	# TODO: Credits-Screen erstellen

func _on_exit_pressed() -> void:
	print("→ Quit Dialog angezeigt")
	quit_dialog.popup_centered()

func _on_quit_confirmed() -> void:
	print("→ Spiel wird beendet")
	get_tree().quit()
