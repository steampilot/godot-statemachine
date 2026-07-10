extends Camera2D

## Advanced Camera Follow Script
## Liest Camera Settings vom Player und implementiert:
## - Damping (Smoothing) für X und Y separat
## - Lookahead (Kamera schaut in Bewegungsrichtung)
## - Zoom Control
## - Ghost System für Jump-Ignore

var player: CharacterBody2D = null
var current_lookahead_offset = 0.0 # Aktueller Lookahead-Offset


func _ready() -> void:
    # Finde Player
    player = get_tree().get_first_node_in_group("player")

    if player == null:
        push_error("Camera: Player nicht gefunden!")
        return

    # Initiale Position
    global_position = player.global_position

    # Position Smoothing deaktivieren - wir machen manuelles Smoothing
    position_smoothing_enabled = false


func _process(delta: float) -> void:
    if player == null:
        return

    if player.camera_fixed:
        # Fixed Camera - bewegt sich nicht
        return

    # Entscheide welcher Position gefolgt werden soll
    var target_position: Vector2

    if player.camera_ignores_jump:
        # Folge dem Ghost (ignoriert vertikale Sprung-Bewegung)
        target_position = player.camera_ghost_position
    else:
        # Folge dem Player direkt
        target_position = player.global_position

    # Lookahead - Kamera schaut in Bewegungsrichtung
    var lookahead_direction = sign(player.velocity.x) # -1 (links), 0 (still), 1 (rechts)
    var target_lookahead = lookahead_direction * player.camera_lookahead

    # Smooth Lookahead Transition
    current_lookahead_offset = lerp(
        current_lookahead_offset,
        target_lookahead,
        player.camera_lookahead_speed * delta
    )

    # Füge Lookahead zum Target hinzu
    target_position.x += current_lookahead_offset

    # Apply Damping (separates Smoothing für X und Y)
    var new_position = global_position

    if player.camera_damping_x > 0:
        new_position.x = lerp(global_position.x, target_position.x, delta * player.camera_damping_x)
    else:
        new_position.x = target_position.x

    if player.camera_damping_y > 0:
        new_position.y = lerp(global_position.y, target_position.y, delta * player.camera_damping_y)
    else:
        new_position.y = target_position.y

    global_position = new_position

    # Apply Zoom
    zoom = Vector2(player.camera_zoom, player.camera_zoom)
