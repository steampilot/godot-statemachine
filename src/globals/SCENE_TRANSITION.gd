extends Node
class_name SCENE_TRANSITION
## Global Singleton für Szenenübergänge
## Verwaltet Fade-Effekte und Übergänge

var transition_active: bool = false
var transition_speed: float = 0.5  # Sekunden für kompletten Fade

var fade_rect: ColorRect = null
var transition_callback: Callable = Callable()

signal transition_started
signal transition_completed

func _ready() -> void:
	set_name("SCENE_TRANSITION")
	_setup_fade_rect()
	print("✓ SCENE_TRANSITION Singleton initialisiert")

func _setup_fade_rect() -> void:
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.color.a = 0.0
	fade_rect.anchor_left = 0.0
	fade_rect.anchor_top = 0.0
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	add_child(fade_rect)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out(duration: float = -1.0) -> void:
	if transition_active:
		return

	transition_active = true
	transition_started.emit()

	if duration <= 0:
		duration = transition_speed

	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	tween.tween_callback(func(): transition_active = false; transition_completed.emit())

func fade_in(duration: float = -1.0) -> void:
	if transition_active:
		return

	transition_active = true
	transition_started.emit()

	if duration <= 0:
		duration = transition_speed

	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	tween.tween_callback(func(): transition_active = false; transition_completed.emit())

func fade_transition(callback: Callable, duration: float = -1.0) -> void:
	if transition_active:
		return

	transition_active = true
	transition_started.emit()

	if duration <= 0:
		duration = transition_speed

	# Fade Out
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration / 2.0)
	tween.tween_callback(func(): callback.call())
	tween.tween_property(fade_rect, "color:a", 0.0, duration / 2.0)
	tween.tween_callback(func(): transition_active = false; transition_completed.emit())

func set_transition_speed(speed: float) -> void:
	transition_speed = max(0.1, speed)

func is_transitioning() -> bool:
	return transition_active

func instant_black() -> void:
	fade_rect.color.a = 1.0

func instant_clear() -> void:
	fade_rect.color.a = 0.0
