extends Node
class_name Motor

## Exekutive Schicht - Physik, Bewegung, Regelwerk
## Interpretiert Intents und setzt sie in physische Bewegung um
## Entscheidet NICHT, welche Animation läuft - das macht der Beobachter

@export var speed: float = 5.0
@export var gravity: float = 9.8
@export var jump_force: float = 5.0

var body: CharacterBody3D
var state: StateFlags

func setup(p_body: CharacterBody3D, p_state: StateFlags):
	body = p_body
	state = p_state

## Interpretiert Intent und wendet sie an
func apply_intent(intent: Intent, delta: float):
	if state.controlled:
		# Gepuppt: Intents werden ignoriert
		return

	match intent.type:
		Intent.Type.MOVE:
			_apply_move(intent.value, delta)
		Intent.Type.INTERACT:
			pass  # Hier würde Interaktionslogik hin, wenn nötig
		Intent.Type.CANCEL:
			pass  # Hier würde Abbruch-Logik hin

## Wendet Bewegung an
func _apply_move(dir: Vector2, delta: float):
	var direction = Vector3(dir.x, 0, dir.y)
	# Optional: Rotation berücksichtigen
	# direction = direction.rotated(Vector3.UP, body.rotation.y)

	body.velocity.x = direction.x * speed
	body.velocity.z = direction.y * speed

## Physics-Tick: Gravität, Bodenkontakt, Move-and-Slide
func physics_tick(delta: float):
	# Gravität anwenden, wenn in der Luft
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta
	else:
		state.grounded = true
		# Sanftes Landen (nur kleine negative Y)
		if body.velocity.y < 0:
			body.velocity.y = 0

	# Physik-Simulation
	body.move_and_slide()

## Lock-Funktionen für Puppeteer
func lock_movement():
	"""Blockiert Bewegungs-Intents"""
	pass

func unlock_movement():
	"""Gibt Bewegungs-Intents wieder frei"""
	pass
