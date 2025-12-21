extends Camera2D
func _physics_process(delta: float) -> void:
    if Input.is_action_pressed("ui_right"):
        position.x += 200 * delta
    if Input.is_action_pressed("ui_left"):
        position.x -= 200 * delta
    if Input.is_action_pressed("ui_down"):
        position.y += 200 * delta
    if Input.is_action_pressed("ui_up"):
        position.y -= 200 * delta