extends CanvasLayer

var player: CharacterBody2D
var showing = true

# UI Nodes
var speed_input: LineEdit
var default_jump_input: LineEdit
var mario_jump_input: LineEdit
var mario_fall_input: LineEdit
var mario_low_jump_input: LineEdit
var ironman_initial_velocity_input: LineEdit
var ironman_initial_hold_input: LineEdit
var ironman_boost_velocity_input: LineEdit
var ironman_boost_hold_input: LineEdit
var coyote_time_input: LineEdit

# Für Panel verstecken/anzeigen
var panel: PanelContainer

func _ready() -> void:
	player = get_tree().root.get_child(0).get_node("Player")
	if player == null:
		push_error("Debug HUD: Player nicht gefunden!")
		return

	create_ui()
	update_ui_from_player()


func create_ui() -> void:
	# Panel für besseres Aussehen
	panel = PanelContainer.new()
	panel.position = Vector2(10, 10)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8)
	panel_style.set_border_enabled_all(true)
	panel_style.set_border_color_all(Color(0, 1, 0, 1))
	panel_style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	# Inner VBox für Label
	var inner_vbox = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 5)
	panel.add_child(inner_vbox)

	# Title
	var title = Label.new()
	title.text = "=== Debug HUD (Press H to toggle) ==="
	title.add_theme_font_size_override("font_size", 14)
	inner_vbox.add_child(title)

	# Separator
	var sep1 = HSeparator.new()
	inner_vbox.add_child(sep1)

	# SPEED
	var speed_hbox = create_input_field("SPEED:", "speed_input")
	inner_vbox.add_child(speed_hbox)
	speed_input = speed_hbox.get_child(1)

	# Separator
	var sep2 = HSeparator.new()
	inner_vbox.add_child(sep2)

	# DEFAULT State
	var default_label = Label.new()
	default_label.text = "--- DEFAULT STATE ---"
	inner_vbox.add_child(default_label)

	var default_jump_hbox = create_input_field("JUMP_VELOCITY:", "default_jump_input")
	inner_vbox.add_child(default_jump_hbox)
	default_jump_input = default_jump_hbox.get_child(1)

	# MARIO State
	var mario_label = Label.new()
	mario_label.text = "--- MARIO STATE ---"
	inner_vbox.add_child(mario_label)

	var mario_jump_hbox = create_input_field("JUMP_VELOCITY:", "mario_jump_input")
	inner_vbox.add_child(mario_jump_hbox)
	mario_jump_input = mario_jump_hbox.get_child(1)

	var mario_fall_hbox = create_input_field("FALL_MULTIPLIER:", "mario_fall_input")
	inner_vbox.add_child(mario_fall_hbox)
	mario_fall_input = mario_fall_hbox.get_child(1)

	var mario_low_hbox = create_input_field("LOW_JUMP_MULTIPLIER:", "mario_low_jump_input")
	inner_vbox.add_child(mario_low_hbox)
	mario_low_jump_input = mario_low_hbox.get_child(1)

	# IRONMAN State
	var ironman_label = Label.new()
	ironman_label.text = "--- IRONMAN STATE (Two-Phase Jump) ---"
	inner_vbox.add_child(ironman_label)

	# Phase 1: Initial Jump
	var ironman_initial_label = Label.new()
	ironman_initial_label.text = "Phase 1: Initial Jump (0.0-0.3s)"
	inner_vbox.add_child(ironman_initial_label)

	var ironman_initial_vel_hbox = create_input_field("INITIAL_VELOCITY:", "ironman_initial_velocity_input")
	inner_vbox.add_child(ironman_initial_vel_hbox)
	ironman_initial_velocity_input = ironman_initial_vel_hbox.get_child(1)

	var ironman_initial_hold_hbox = create_input_field("INITIAL_HOLD_TIME:", "ironman_initial_hold_input")
	inner_vbox.add_child(ironman_initial_hold_hbox)
	ironman_initial_hold_input = ironman_initial_hold_hbox.get_child(1)

	# Phase 2: Boost
	var ironman_boost_label = Label.new()
	ironman_boost_label.text = "Phase 2: Boost/Düsen (0.3-1.3s)"
	inner_vbox.add_child(ironman_boost_label)

	var ironman_boost_vel_hbox = create_input_field("BOOST_VELOCITY:", "ironman_boost_velocity_input")
	inner_vbox.add_child(ironman_boost_vel_hbox)
	ironman_boost_velocity_input = ironman_boost_vel_hbox.get_child(1)

	var ironman_boost_hold_hbox = create_input_field("BOOST_HOLD_TIME:", "ironman_boost_hold_input")
	inner_vbox.add_child(ironman_boost_hold_hbox)
	ironman_boost_hold_input = ironman_boost_hold_hbox.get_child(1)

	# Separator
	var sep3 = HSeparator.new()
	inner_vbox.add_child(sep3)

	# Jump Type
	var type_label = Label.new()
	type_label.text = "--- JUMP TYPE (Coyote Time) ---"
	inner_vbox.add_child(type_label)

	var coyote_time_hbox = create_input_field("COYOTE_TIME:", "coyote_time_input")
	inner_vbox.add_child(coyote_time_hbox)
	coyote_time_input = coyote_time_hbox.get_child(1)


func create_input_field(label_text: String, input_name: String) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 5)
	hbox.custom_minimum_size.y = 24

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 180
	hbox.add_child(label)

	var input = LineEdit.new()
	input.custom_minimum_size.x = 80
	input.text_changed.connect(_on_input_changed.bind(input_name, input))
	hbox.add_child(input)

	return hbox


func update_ui_from_player() -> void:
	speed_input.text = str(player.SPEED)
	default_jump_input.text = str(player.DEFAULT_JUMP_VELOCITY)
	mario_jump_input.text = str(player.MARIO_JUMP_VELOCITY)
	mario_fall_input.text = str(player.MARIO_FALL_MULTIPLIER)
	mario_low_jump_input.text = str(player.MARIO_LOW_JUMP_MULTIPLIER)
	ironman_initial_velocity_input.text = str(player.IRONMAN_INITIAL_VELOCITY)
	ironman_initial_hold_input.text = str(player.IRONMAN_INITIAL_HOLD_TIME)
	ironman_boost_velocity_input.text = str(player.IRONMAN_BOOST_VELOCITY)
	ironman_boost_hold_input.text = str(player.IRONMAN_BOOST_HOLD_TIME)
	coyote_time_input.text = str(player.COYOTE_TIME)


func _on_input_changed(text: String, input_name: String, input: LineEdit) -> void:
	if text.is_empty():
		return

	var value = text.to_float()

	match input_name:
		"speed_input":
			player.SPEED = value
		"default_jump_input":
			player.DEFAULT_JUMP_VELOCITY = value
		"mario_jump_input":
			player.MARIO_JUMP_VELOCITY = value
		"mario_fall_input":
			player.MARIO_FALL_MULTIPLIER = value
		"mario_low_jump_input":
			player.MARIO_LOW_JUMP_MULTIPLIER = value
		"ironman_initial_velocity_input":
			player.IRONMAN_INITIAL_VELOCITY = value
		"ironman_initial_hold_input":
			player.IRONMAN_INITIAL_HOLD_TIME = value
		"ironman_boost_velocity_input":
			player.IRONMAN_BOOST_VELOCITY = value
		"ironman_boost_hold_input":
			player.IRONMAN_BOOST_HOLD_TIME = value
		"coyote_time_input":
			player.COYOTE_TIME = value


func _process(_delta: float) -> void:
	# Toggle mit H-Taste
	if Input.is_action_just_pressed("ui_home") or Input.is_key_pressed(KEY_H):
		showing = !showing
		panel.visible = showing
