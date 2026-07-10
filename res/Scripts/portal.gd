extends Area2D

## Portal-System für Levelübergänge und Spawnpoint-Navigation
## Ein Portal führt entweder zu einem anderen Spawnpoint im gleichen Level
## oder zu einem Spawnpoint in einem anderen Level

signal player_entered_portal
signal player_exited_portal

# Zielkonfiguration
@export var target_level_path: String = "" # Leer = gleiches Level, sonst Pfad zur Scene
@export var target_spawn_point_id: String = "spawn_default" # ID des Spawnpoints

# Interaktions-Einstellungen
@export var auto_transition: bool = true # Automatischer Transport bei Enter
@export var transition_delay: float = 0.5 # Verzögerung vor Transport

# Interne State
var player_in_area: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    if target_spawn_point_id.is_empty():
        push_warning("Portal '%s': Keine target_spawn_point_id gesetzt!" % name)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_area = true
        player_entered_portal.emit()

        if auto_transition:
            await get_tree().create_timer(transition_delay).timeout
            if player_in_area: # Prüfe ob Spieler noch in Area ist
                _activate_portal()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_area = false
        player_exited_portal.emit()

func _unhandled_input(event: InputEvent) -> void:
    if not auto_transition and player_in_area:
        if event.is_action_pressed("ui_accept"):
            _activate_portal()

func _activate_portal() -> void:
    if target_spawn_point_id.is_empty():
        push_error("Portal '%s': Keine target_spawn_point_id definiert!" % name)
        return

    if target_level_path.is_empty():
        # Spawnpoint im gleichen Level
        _spawn_at_point_in_level(target_spawn_point_id)
    else:
        # Spawnpoint in anderem Level
        _spawn_at_point_in_new_level(target_level_path, target_spawn_point_id)

func _spawn_at_point_in_level(spawn_id: String) -> void:
    print("→ Portal aktiviert: Teleportiere zum Spawnpoint '%s'" % spawn_id)
    # TODO: Spieler zum Spawnpoint im aktuellen Level teleportieren
    # var spawn_point = get_tree().root.find_child(spawn_id, true, false)
    # if spawn_point:
    #     player.global_position = spawn_point.global_position
    #     player.velocity = Vector2.ZERO

func _spawn_at_point_in_new_level(level_path: String, spawn_id: String) -> void:
    print("→ Portal aktiviert: Lade Level '%s' mit Spawnpoint '%s'" % [level_path, spawn_id])
    # TODO: Level laden und Spieler beim Spawnpoint spawnen
    # LEVEL_LOADER.load_level_with_spawn(level_path, spawn_id)
