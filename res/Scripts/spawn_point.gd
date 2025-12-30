extends Node2D

## Spawnpoint für Levelein- und Aufstiege
## Definiert die Position, wo der Spieler ein Level betritt oder respawnt

@export var spawn_id: String = "spawn_default" # Eindeutige ID dieses Spawnpoints

func _ready() -> void:
	# Optional: Visuelle Markierung im Editor
	if not Engine.is_editor_hint():
		# In Runtime können wir dies zur Debugging ausblenden
		pass

## Gibt die Spawnposition zurück
func get_spawn_position() -> Vector2:
	return global_position

## Gibt alle Eigenschaften dieses Spawnpoints zurück
func get_spawn_data() -> Dictionary:
	return {
		"spawn_id": spawn_id,
		"position": global_position,
		"rotation": global_rotation
	}
