extends Node
class_name Engine

## Exekutive Schicht - Physik, Bewegung, Regelwerk (2D Sidescroller)
## Interpretiert Intents und setzt sie in physische Bewegung um
## Entscheidet NICHT, welche Animation läuft - das macht der Beobachter

@export var speed: float = 100.0
@export var gravity: float = 500.0
@export var jump_force: float = 300.0

var body: CharacterBody2D
var state: StateFlags

func setup(p_body: CharacterBody2D, p_state: StateFlags):
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
			pass # Hier würde Interaktionslogik hin, wenn nötig
		Intent.Type.CANCEL:
			pass # Hier würde Abbruch-Logik hin

## Wendet Bewegung an (2D Sidescroller)
func _apply_move(dir: Vector2, delta: float):
	# 2D: nur x (left-right)
	# Y wird durch Gravität gesteuert
	body.velocity.x = dir.x * speed

## Physics-Tick: Gravität, Bodenkontakt, Move-and-Slide (2D)
func physics_tick(delta: float):
	# Gravität anwenden, wenn in der Luft
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
		state.grounded = false
	else:
		state.grounded = true
		# Sanftes Landen
		if body.velocity.y > 0:
			body.velocity.y = 0

	# Physik-Simulation (2D)
	body.move_and_slide()

## Lock-Funktionen für Puppeteer
func lock_movement():
	# Blockiert Bewegungs-Intents
	pass

func unlock_movement():
	# Gibt Bewegungs-Intents wieder frei
	pass
