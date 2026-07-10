extends CharacterBody2D
class_name Platformer
## Beispiel Platformer Character mit PhysicsComponent
## Zeigt wie Jump mit positiver Force funktioniert
## WICHTIG: Platformer KANN sein, aber sollte auch resettbar sein

@onready var health: HealthComponent = $HealthComponent
@onready var velocity_comp: VelocityComponent = $VelocityComponent
@onready var physics_comp: PhysicsComponent = $PhysicsComponent
@onready var death_comp: DeathComponent = $DeathComponent
@onready var intent_emitter: IntentEmitter = $IntentEmitter

var can_jump: bool = true

func _ready() -> void:
    health.health_changed.connect(_on_health_changed)
    health.health_depleted.connect(_on_health_depleted)

    physics_comp.landed.connect(_on_landed)
    physics_comp.jumped.connect(_on_jumped)

    # Für Platformer: Kann auto_queue_free sein (Entity, nicht Player)
    death_comp.auto_queue_free = true

func _process(_delta: float) -> void:
    if death_comp.is_dead_check():
        return

    var intents = intent_emitter.collect()
    for intent in intents:
        handle_intent(intent)

func handle_intent(intent: Intent) -> void:
    match intent.type:
        Intent.Type.MOVE:
            # Horizontal Movement via VelocityComponent
            velocity_comp.set_direction(intent.value)
        Intent.Type.INTERACT:
            # Jump - positive Force!
            if physics_comp.is_on_floor():
                physics_comp.jump(100.0)  # POSITIVE = nach oben
        Intent.Type.CANCEL:
            velocity_comp.stop()

func take_damage(amount: int) -> void:
    health.take_damage(amount)

func _on_health_changed(from: int, damage: int, max_hp: int) -> void:
    print("Platformer: %d -> %d / %d HP" % [from, from - damage, max_hp])

func _on_health_depleted() -> void:
    print("Platformer health depleted! DeathComponent wird queue_free aufrufen...")
    # DeathComponent handelt alles

func _on_jumped(force: float) -> void:
    print("Jumped with force: %.1f" % force)

func _on_landed() -> void:
    print("Landed!")
