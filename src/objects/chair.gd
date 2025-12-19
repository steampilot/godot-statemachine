extends Puppeteer
class_name Chair

## Stuhl - Puppeteer-Objekt (2D Sidescroller)
## Der Stuhl kontrolliert den Player während des Sitzens

@onready var area: Area2D = $Area2D
@onready var seat_anchor: Node2D = $SeatAnchor
@onready var sprite: Sprite2D = $Sprite2D

var occupant: Player = null
var initial_player_position: Vector3

func _ready():
	# Collision-Signale
	area.body_entered.connect(_on_area_entered)
	area.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node2D):
	if body is Player:
		occupant = body
		print("🪑 Player near chair")

func _on_area_exited(body: Node2D):
	if body == occupant:
		occupant = null
		print("🪑 Player left chair area")

## Input-Handling für Sit/Stand
func _unhandled_input(event: InputEvent):
	if not occupant:
		return

	if event.is_action_pressed("ui_accept"):
		if occupant.state.controlled and occupant.puppeteer == self:
			# Aufstehen
			get_tree().root.set_input_as_handled()
			release()
		elif not occupant.state.controlled:
			# Sitzen
			get_tree().root.set_input_as_handled()
			capture(occupant)

## ===== PUPPETEER INTERFACE =====

func on_capture(player: Player):
	print("🪑 [Chair] Capturing player")
	initial_player_position = player.global_position
	player.engine.lock_movement()
	_play_sit_animation(player)

func on_intent(intent: Intent):
	# Während sitzen: nur Interact wird beachtet (siehe _unhandled_input)
	pass

func on_release(player: Player):
	print("🪑 [Chair] Releasing player")
	player.engine.unlock_movement()
	_play_stand_animation(player)

## ===== ANIMATION HELPERS =====

func _play_sit_animation(player: Player):
	# TODO: Hier würde die Sit-Animation starten
	if player.has_node("AnimationPlayer"):
		var anim_player = player.get_node("AnimationPlayer")
		if anim_player.has_animation("sit"):
			anim_player.play("sit")
	print("  ▶️ Playing: sit animation")

func _play_stand_animation(player: Player):
	# TODO: Hier würde die Stand-Animation starten
	if player.has_node("AnimationPlayer"):
		var anim_player = player.get_node("AnimationPlayer")
		if anim_player.has_animation("stand"):
			anim_player.play("stand")
	print("  ▶️ Playing: stand animation")

## Public API

func is_occupied() -> bool:
	return occupant != null and occupant.state.controlled
