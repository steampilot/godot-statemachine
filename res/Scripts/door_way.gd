extends Area2D

## Doorway Component für Türen und Level-Exits
## Lädt eine neue Szene wenn der Spieler die Area betritt

signal player_entered_doorway
signal player_exited_doorway

@export var target_scene: PackedScene
@export var transition_delay: float = 0.5
@export var auto_transition: bool = true

var player_in_area: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if not target_scene:
		push_warning("Doorway '%s' hat keine target_scene gesetzt!" % name)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_entered_doorway.emit()

		if auto_transition and target_scene:
			await get_tree().create_timer(transition_delay).timeout
			if player_in_area: # Check if player is still in area
				_load_target_scene()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_exited_doorway.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not auto_transition and player_in_area:
		if event.is_action_pressed("ui_accept"): # E oder Enter
			_load_target_scene()

func _load_target_scene() -> void:
	if not target_scene:
		push_error("Doorway '%s': Keine target_scene definiert!" % name)
		return

	print("→ Doorway aktiviert, lade Szene via LevelLoader")
	LevelLoader.load_level_packed(target_scene)
