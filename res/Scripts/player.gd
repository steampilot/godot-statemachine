class_name Player
extends CharacterBody2D

@export var max_health: int = 100

@export var down_gravity_multiplier: float = 1.5
@export var max_speed: float = 400.0
@export var acceleration: float = 2000.0
@export var deceleration: float = 1500.0
@export var turn_speed: float = 1.5


var health: int = max_health

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var state_machine: StateMachine = %StateMachine

func _ready() -> void:
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func receive_damage(amount: int) -> void:
	print("%s received %d damage!" % [self.name, amount])
	health -= amount
	print("%s Is now at health: %d of %d" % [self.name, health, max_health])
	sprite.play("hurt")
	if health <= 0:
		print("%s has been defeated!" % [self.name])
