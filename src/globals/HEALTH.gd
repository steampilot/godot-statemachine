extends Node
class_name HEALTH
## Global Singleton für Entity Health Management
## Verwaltet Gesundheit für beliebige Entities: Player, Enemies, Doors, Locks, Barrels, etc.

# Entity Health Data Struktur
class HealthData:
	var entity_id: String
	var entity_ref: Node  # Referenz zum Objekt
	var current_health: int
	var max_health: int
	var is_alive: bool = true
	var on_death_callback: Callable = Callable()  # Optional callback bei Tod
	var damage_reduction: float = 0.0  # 0.0 - 1.0 Faktor
	var invulnerable: bool = false
	var invulnerability_timer: float = 0.0

# Registry aller Entities mit Health
var entities: Dictionary = {}  # entity_id -> HealthData

# Signals (generisch für alle Entities)
signal health_changed(entity_id: String, current: int, max_val: int)
signal entity_damaged(entity_id: String, damage: int, remaining_health: int)
signal entity_healed(entity_id: String, amount: int, new_health: int)
signal entity_died(entity_id: String, entity_ref: Node)
signal entity_registered(entity_id: String)
signal entity_unregistered(entity_id: String)

func _ready() -> void:
	set_name("HEALTH")
	print("✓ HEALTH Singleton initialisiert (Entity-basiert)")

func _process(delta: float) -> void:
	# Invulnerabilität timer update für alle Entities
	for entity_id in entities:
		var health_data: HealthData = entities[entity_id]
		if health_data.invulnerable and health_data.invulnerability_timer > 0:
			health_data.invulnerability_timer -= delta
			if health_data.invulnerability_timer <= 0:
				health_data.invulnerable = false

## Registriert eine neue Entity mit Health
func register_entity(entity_id: String, entity_ref: Node, max_health: int, on_death: Callable = Callable()) -> void:
	if entities.has(entity_id):
		push_warning("Entity %s existiert bereits" % entity_id)
		return

	var health_data = HealthData.new()
	health_data.entity_id = entity_id
	health_data.entity_ref = entity_ref
	health_data.max_health = max_health
	health_data.current_health = max_health
	health_data.on_death_callback = on_death

	entities[entity_id] = health_data
	entity_registered.emit(entity_id)

## Entfernt Entity aus Registry
func unregister_entity(entity_id: String) -> void:
	if entities.has(entity_id):
		entities.erase(entity_id)
		entity_unregistered.emit(entity_id)

## Gibt Schaden an Entity aus
func deal_damage(entity_id: String, damage: int) -> void:
	if not entities.has(entity_id):
		push_error("Entity nicht gefunden: %s" % entity_id)
		return

	var health_data: HealthData = entities[entity_id]

	# Keine Schaden wenn invulnerabel
	if health_data.invulnerable:
		return

	# Damage Reduction anwenden
	var actual_damage = int(damage * (1.0 - health_data.damage_reduction))
	health_data.current_health -= actual_damage

	entity_damaged.emit(entity_id, actual_damage, health_data.current_health)
	health_changed.emit(entity_id, health_data.current_health, health_data.max_health)

	# Prüfe ob Entity gestorben ist
	if health_data.current_health <= 0:
		_on_entity_death(entity_id, health_data)

## Heilt eine Entity
func heal_entity(entity_id: String, amount: int) -> void:
	if not entities.has(entity_id):
		push_error("Entity nicht gefunden: %s" % entity_id)
		return

	var health_data: HealthData = entities[entity_id]
	var old_health = health_data.current_health
	health_data.current_health = min(health_data.current_health + amount, health_data.max_health)
	var healed_amount = health_data.current_health - old_health

	entity_healed.emit(entity_id, healed_amount, health_data.current_health)
	health_changed.emit(entity_id, health_data.current_health, health_data.max_health)

## Setzt Entity in Invulnerabilität
func set_invulnerable(entity_id: String, duration: float) -> void:
	if entities.has(entity_id):
		entities[entity_id].invulnerable = true
		entities[entity_id].invulnerability_timer = duration

## Setzt Damage Reduction für Entity (0.0 - 1.0)
func set_damage_reduction(entity_id: String, reduction: float) -> void:
	if entities.has(entity_id):
		entities[entity_id].damage_reduction = clamp(reduction, 0.0, 1.0)

## Gibt aktuelle Health einer Entity zurück
func get_health(entity_id: String) -> int:
	if entities.has(entity_id):
		return entities[entity_id].current_health
	return 0

## Gibt max Health einer Entity zurück
func get_max_health(entity_id: String) -> int:
	if entities.has(entity_id):
		return entities[entity_id].max_health
	return 0

## Gibt Health Prozentsatz (0-100) zurück
func get_health_percent(entity_id: String) -> float:
	if entities.has(entity_id):
		var health_data: HealthData = entities[entity_id]
		return (float(health_data.current_health) / float(health_data.max_health)) * 100.0
	return 0.0

## Prüft ob Entity lebt
func is_alive(entity_id: String) -> bool:
	if entities.has(entity_id):
		return entities[entity_id].is_alive
	return false

## Gibt Entity Reference zurück
func get_entity(entity_id: String) -> Node:
	if entities.has(entity_id):
		return entities[entity_id].entity_ref
	return null

## Gibt alle lebenden Entities zurück (Optional: mit bestimmtem Prefix)
func get_alive_entities(prefix: String = "") -> Array:
	var alive = []
	for entity_id in entities:
		var health_data: HealthData = entities[entity_id]
		if health_data.is_alive:
			if prefix.is_empty() or entity_id.begins_with(prefix):
				alive.append(entity_id)
	return alive

## Zählt lebende Entities mit bestimmtem Prefix (z.B. "enemy_" für Gegner)
func count_alive_entities(prefix: String) -> int:
	return get_alive_entities(prefix).size()

## Internal: Handler für Entity Death
func _on_entity_death(entity_id: String, health_data: HealthData) -> void:
	health_data.current_health = 0
	health_data.is_alive = false

	entity_died.emit(entity_id, health_data.entity_ref)

	# Callback aufrufen wenn vorhanden
	if health_data.on_death_callback.is_valid():
		health_data.on_death_callback.call()

## Debug: Gibt alle registrierten Entities aus
func debug_print_entities() -> void:
	print("\n=== HEALTH Registry Debug ===")
	for entity_id in entities:
		var hd: HealthData = entities[entity_id]
		var status = "ALIVE" if hd.is_alive else "DEAD"
		print("  %s: %d/%d HP [%s]" % [entity_id, hd.current_health, hd.max_health, status])
	print("================================\n")

