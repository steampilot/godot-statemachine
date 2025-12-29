class_name HealthData
extends Resource

## Resource für Entity Health Data
## Speichert alle gesundheitsbezogenen Informationen für eine Entity

@export var entity_id: String = ""
@export var max_health: int = 100
@export var current_health: int = 100
@export var is_alive: bool = true
@export var damage_reduction: float = 0.0 ## 0.0 - 1.0 Faktor
@export var invulnerable: bool = false

var entity_ref: Node # Nicht exportiert - Laufzeit Referenz
var on_death_callback: Callable = Callable() # Nicht exportiert - Laufzeit Callback
var invulnerability_timer: float = 0.0

func _init(p_entity_id: String = "", p_entity_ref: Node = null, p_max_health: int = 100,
	p_on_death: Callable = Callable()) -> void:
	entity_id = p_entity_id
	entity_ref = p_entity_ref
	max_health = p_max_health
	current_health = p_max_health
	on_death_callback = p_on_death
