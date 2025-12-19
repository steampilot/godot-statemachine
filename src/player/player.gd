extends CharacterBody2D
class_name Player

## Orchestrator - koordiniert Intent-Sammlung, Puppetry und Motor
## Input → Intent → (Player | Puppeteer) → Motor → Physik

@onready var intent_emitter: IntentEmitter = $IntentEmitter
@onready var motor: Motor = $Motor
@onready var state: StateFlags = $StateFlags

## Aktueller Puppeteer (wenn controlled)
var puppeteer: Node = null

func _ready():
	motor.setup(self, state)

func _physics_process(delta):
	## Intents sammeln
	var intents = intent_emitter.collect()

	## Routing: Controlled → Puppeteer, sonst → Motor
	if state.controlled and puppeteer:
		for intent in intents:
			puppeteer.on_intent(intent)
	else:
		for intent in intents:
			motor.apply_intent(intent, delta)

	## Motor macht Physik
	motor.physics_tick(delta)

## Capture-Schnittstelle (wird vom Puppeteer aufgerufen)
func capture(puppeteer_node: Node):
	state.controlled = true
	puppeteer = puppeteer_node
	if puppeteer.has_method("on_capture"):
		puppeteer.on_capture(self)

## Release-Schnittstelle (wird vom Puppeteer aufgerufen)
func release():
	state.controlled = false
	if puppeteer and puppeteer.has_method("on_release"):
		puppeteer.on_release(self)
	puppeteer = null
