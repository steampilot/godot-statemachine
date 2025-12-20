class_name MAIN
extends Node
## Global Singleton für zentrale Game-Verwaltung
## Verwaltet: Player, UI, Game States, Scores, etc.

# Signals
signal level_changed(level: int)
signal score_changed(score: int)
signal items_collected(count: int)
signal game_paused_state_changed(is_paused: bool)

# Globale Spielzustände
var current_level: int = 1
var total_score: int = 0
var collected_items: int = 0
var game_paused: bool = false

# Globale State Machine
@onready var game_state_machine: GameStateMachine = GameStateMachine.new()

# Globale Szenen-Referenzen
@onready var player: CharacterBody2D = null
@onready var ui_root: Control = null
@onready var main_menu: MainMenu = null
@onready var game_scene: Node = null

func _ready() -> void:
	# Singleton-Pattern wird über AutoLoad verwaltet
	set_name("MAIN")
	print("✓ MAIN Singleton initialisiert")

func get_player() -> CharacterBody2D:
	return player

func set_player(p: CharacterBody2D) -> void:
	player = p

func get_ui_root() -> Control:
	return ui_root

func set_ui_root(u: Control) -> void:
	ui_root = u

func add_score(amount: int) -> void:
	total_score += amount
	score_changed.emit(total_score)

func reset_score() -> void:
	total_score = 0
	score_changed.emit(total_score)

func collect_item() -> void:
	collected_items += 1
	items_collected.emit(collected_items)

func load_level(level_num: int) -> void:
	current_level = level_num
	level_changed.emit(current_level)

func set_pause_state(paused: bool) -> void:
	game_paused = paused
	get_tree().paused = paused
	game_paused_state_changed.emit(paused)

func toggle_pause() -> void:
	set_pause_state(!game_paused)

func reset_game() -> void:
	current_level = 1
	total_score = 0
	collected_items = 0
	game_paused = false
	score_changed.emit(total_score)
	items_collected.emit(collected_items)
	level_changed.emit(current_level)
