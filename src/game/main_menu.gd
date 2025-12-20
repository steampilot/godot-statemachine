class_name MainMenu
extends Control

## Main Menu UI - Splash Screen mit Start Button

signal load_scene_requested(scene_path: String)

@onready var start_button: Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	# Zentrieren
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -200
	offset_top = -100
	offset_right = 200
	offset_bottom = 100

func _on_start_pressed() -> void:
	load_scene_requested.emit("res://scenes/main.tscn")
