extends CharacterBody2D
class_name Player
## Player Node - IMMER bestehen bleiben für Camera, AudioListener, etc
## Nutzt mehrere Components für Modularität
## Death wird durch DeathComponent gehandelt

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent
@onready var physics_comp: PhysicsComponent = $PhysicsComponent
@onready var death_comp: DeathComponent = $DeathComponent
@onready var intent_emitter: IntentEmitter = $IntentEmitter
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
    # Health Signals
    health.health_changed.connect(_on_health_changed)
    health.health_depleted.connect(_on_health_depleted)

    # Physics Signals
    physics_comp.landed.connect(_on_landed)
    physics_comp.jumped.connect(_on_jumped)

    # Death Signals
    death_comp.death_started.connect(_on_death_started)
    death_comp.death_finished.connect(_on_death_finished)

    print("✓ Player initialized with Camera & AudioListener preserved")

func _process(_delta: float) -> void:
    # Nur wenn nicht tot
    if death_comp.is_dead_check():
        return

    # Intent-basierte Eingabe
    var intents = intent_emitter.collect()
    for intent in intents:
        handle_intent(intent)

func handle_intent(intent: Intent) -> void:
    match intent.type:
        Intent.Type.MOVE:
            velocity_comp.set_direction(intent.value)
        Intent.Type.INTERACT:
            interact()
        Intent.Type.CANCEL:
            velocity_comp.stop()

func interact() -> void:
    print("Player interacted!")

## Damage zufügen
func take_damage(amount: int) -> void:
    health.take_damage(amount)

## Heilen
func heal(amount: int) -> void:
    health.restore_health(amount)

## Signals
func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
    var percent = health.get_health_percent()
    print("Player: %d → %d / %d HP (%.0f%%)" % [from, from - damage, max_hp, percent])
    # HUD Update, Damage-Flash, etc.

func _on_health_depleted() -> void:
    print("Player health depleted! Death sequence started by DeathComponent...")
    # DeathComponent handelt alles

func _on_death_started() -> void:
    print("Death sequence started - disabling input")
    # Disable Input, Show Animation, etc.

func _on_death_finished() -> void:
    print("Death sequence finished - Player still alive but disabled")
    # Game Over Screen, Respawn Menu, etc.
    # ABER NICHT queue_free!

func _on_landed() -> void:
    print("Player landed")

func _on_jumped(force: float) -> void:
    print("Jumped with force: %.1f" % force)

## WICHTIG: Player kann resetten ohne queue_free
func reset_player() -> void:
    health.reset()
    velocity_comp.stop()
    physics_comp.stop_vertical_movement()
    death_comp.is_dead = false

    # Re-enable wenn notwendig
    if has_node("Sprite2D"):
        get_node("Sprite2D").modulate.a = 1.0

    process_mode = Node.PROCESS_MODE_INHERIT
    print("Player reset!")
