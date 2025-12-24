extends Node2D

## Schwert-Waffe für den Spieler
## Handhabt Attack-States, Hitboxes und Damage

signal attack_started
signal attack_hit(target)
signal attack_finished

# Attack State
enum AttackState {
	IDLE,
	ATTACKING,
	COOLDOWN
}

# Weapon Stats
# Schaden pro Treffer
var damage: int = 10
# Dauer des Attack-Swings in Sekunden
var attack_duration: float = 0.3
# Cooldown zwischen Attacks
var attack_cooldown: float = 0.5

var current_state: AttackState = AttackState.IDLE
var attack_timer: float = 0.0
var cooldown_timer: float = 0.0

# Combo System
# Anzahl möglicher Combo-Hits
var max_combo: int = 3
# Aktueller Combo-Counter
var current_combo: int = 0
# Zeit-Fenster für Combo-Input
var combo_window: float = 0.4
var combo_timer: float = 0.0

# Hitbox Tracking - verhindert mehrfache Treffer pro Attack
var hit_targets: Array = []

# Hitbox Position
# Offset von Player-Position (positive = rechts, negative = links)
var hitbox_offset: float = 30.0

# Node References
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	# Hitbox initial deaktivieren
	if hitbox:
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _process(delta: float) -> void:
	# Update Timers
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()

	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			current_state = AttackState.IDLE

	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()


func attack() -> bool:
	"""
	Führt einen Attack aus.
	Returns true wenn Attack gestartet wurde, false wenn nicht möglich
	"""
	# Check ob Attack möglich ist
	if current_state == AttackState.COOLDOWN:
		return false

	# Wenn bereits am Attackieren, checke Combo
	if current_state == AttackState.ATTACKING:
		if current_combo < max_combo and combo_timer > 0:
			# Combo möglich - queue next attack
			current_combo += 1
			return true
		return false

	# Start Attack
	start_attack()
	return true


func start_attack() -> void:
	"""
	Startet den Attack
	"""
	current_state = AttackState.ATTACKING
	attack_timer = attack_duration
	combo_timer = combo_window
	hit_targets.clear()

	# Update Hitbox Position basierend auf Player Richtung
	update_hitbox_position()

	# Aktiviere Hitbox
	if hitbox:
		hitbox.monitoring = true
	
	attack_started.emit()


func end_attack() -> void:
	"""
	Beendet den Attack und startet Cooldown
	"""
	current_state = AttackState.COOLDOWN
	cooldown_timer = attack_cooldown

	# Deaktiviere Hitbox
	if hitbox:
		hitbox.monitoring = false
	
	attack_finished.emit()


func reset_combo() -> void:
	"""
	Setzt den Combo-Counter zurück
	"""
	current_combo = 0


func update_hitbox_position() -> void:
	"""
	Aktualisiert die Hitbox-Position basierend auf Player-Richtung
	"""
	if not collision_shape:
		return

	var parent = get_parent()
	if parent and parent.has_node("Sprite"):
		var player_sprite = parent.get_node("Sprite")
		if player_sprite.flip_h:
			# Player schaut nach links
			collision_shape.position.x = - hitbox_offset
		else:
			# Player schaut nach rechts
			collision_shape.position.x = hitbox_offset


func _on_hitbox_body_entered(body: Node2D) -> void:
	"""
	Wird aufgerufen wenn Hitbox einen Body trifft
	"""
	# Verhindere mehrfache Treffer pro Attack
	if body in hit_targets:
		return

	hit_targets.append(body)

	# Check ob Body ein Enemy ist (hat HealthComponent oder take_damage Methode)
	if body.has_method("take_damage"):
		body.take_damage(damage)
		attack_hit.emit(body)
	elif body.has_node("HealthComponent"):
		var health_comp = body.get_node("HealthComponent")
		if health_comp.has_method("take_damage"):
			health_comp.take_damage(damage)
			attack_hit.emit(body)


func can_attack() -> bool:
	"""
	Prüft ob Attack möglich ist
	"""
	return current_state == AttackState.IDLE or (
		current_state == AttackState.ATTACKING
		and current_combo < max_combo
		and combo_timer > 0
	)


func is_attacking() -> bool:
	"""
	Gibt zurück ob gerade attackiert wird
	"""
	return current_state == AttackState.ATTACKING


func get_attack_direction() -> Vector2:
	"""
	Gibt die Richtung des Attacks zurück (basierend auf Parent Player Sprite flip)
	"""
	var parent = get_parent()
	if parent and parent.has_node("Sprite"):
		var player_sprite = parent.get_node("Sprite")
		if player_sprite.flip_h:
			return Vector2.LEFT
	return Vector2.RIGHT
