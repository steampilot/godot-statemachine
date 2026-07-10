class_name LadderGrabState

extends State
## State for climbing ladders (TileSet-based)
## Handles vertical and horizontal movement on ladders without gravity
## Based on Mida Pecheux tutorial approach with TileMap integration
##
## SETUP REQUIREMENTS:
## 1. Create a TileMapLayer for ladder tops/one-way platforms
## 2. Add that TileMapLayer to the global group "OneWayPlatforms"
## 3. The player will automatically toggle collision_enabled on this group
##    when climbing DOWN (disabled) or UP/exiting (enabled)
##
## This allows climbing through one-way platforms from below without complex
## layer mask manipulation - just toggle the entire layer on/off!

func enter() -> void:
    super.enter()
    print("Entered Ladder Grab State")

    # Disable gravity while on ladder
    gravity_multiplier = 0.0

    # Stop all momentum when grabbing ladder
    parent.velocity = Vector2.ZERO

    if parent.sprite:
        parent.sprite.pause()

func exit() -> void:
    print("Exited Ladder Grab State")

    # Re-enable gravity
    gravity_multiplier = 1.0

    # Re-enable one-way platform collision
    parent.toggle_oneway_platforms(true)

func process_input(event: InputEvent) -> State:
    # Allow jumping off ladder
    if event.is_action_pressed(INPUT_ACTIONS.JUMP):
        return states.get("jump")

    # Allow attacking from ladder
    if event.is_action_pressed(INPUT_ACTIONS.ATTACK):
        return states.get("attack")

    return null

func process_physics(_delta: float) -> State:
    # Check if player left ladder area (collision layer)
    if not parent.on_ladder:
        # If on floor, transition to idle
        if parent.is_on_floor():
            return states.get("idle")
        # Otherwise fall
        return states.get("fall")

    # Get input directions
    var vertical_input = Input.get_axis(INPUT_ACTIONS.MOVE_UP, INPUT_ACTIONS.MOVE_DOWN)
    var horizontal_input = Input.get_axis(INPUT_ACTIONS.MOVE_LEFT, INPUT_ACTIONS.MOVE_RIGHT)

    # Dynamic OneWay platform handling based on direction
    if vertical_input > 0:
        # Moving DOWN - disable one-way platforms to fall through
        parent.toggle_oneway_platforms(false)
    else:
        # Moving UP or IDLE - enable one-way platforms
        parent.toggle_oneway_platforms(true)

    # Calculate climb speed (use parent's configured values)
    var this_climb_speed = parent.max_speed * parent.climb_speed

    # Apply movement
    parent.velocity.x = horizontal_input * this_climb_speed
    parent.velocity.y = vertical_input * this_climb_speed

    # Handle animation
    if abs(vertical_input) > 0.1:
        # Climbing - play animation
        if parent.sprite and not parent.sprite.is_playing():
            parent.sprite.play()
    else:
        # Not moving vertically - pause animation
        if parent.sprite and parent.sprite.is_playing():
            parent.sprite.pause()

    # Update sprite direction based on horizontal movement
    if abs(horizontal_input) > 0.1:
        parent.sprite.flip_h = horizontal_input < 0

    parent.move_and_slide()

    # Check if player climbed off to the side and is now grounded
    if parent.is_on_floor() and abs(horizontal_input) > 0.1:
        # Moved off ladder sideways onto floor
        if abs(parent.velocity.x) > 10.0:
            return states.get("run")
        return states.get("idle")

    return null