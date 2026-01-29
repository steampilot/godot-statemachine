extends Area2D
class_name KillZone
## Kill Zone - für Entities die rausfallen (unten am Bild)
## Player: respawnt, Enemy/Objects: werden gelöscht

@export var respawn_position: Vector2 = Vector2.ZERO
@export var player_respawn_health: int = 100

signal entity_fell(entity: Node)
signal player_respawned

func _ready() -> void:
    body_entered.connect(_on_body_entered)

    if respawn_position == Vector2.ZERO:
        respawn_position = position

    print("✓ KillZone initialized at position: %s" % respawn_position)

func _on_body_entered(body: Node2D) -> void:
    if not body:
        return

    entity_fell.emit(body)
    print("KillZone: %s fell!" % body.name)

    # Spezial-Handling für Player
    if body is Player or body.get_script().get_class() == "Player":
        _respawn_player(body)
    # Für andere Entities (Enemy, etc.)
    else:
        _kill_entity(body)

## Player respawnen
func _respawn_player(player: Node) -> void:
    print("Respawning player at: %s" % respawn_position)

    # Player zu Spawn-Position teleportieren
    player.global_position = respawn_position

    # Health resetten
    if player.has_node("HealthComponent"):
        var health = player.get_node("HealthComponent")
        health.set_health(player_respawn_health)

    # Reset Player komplett
    if player.has_method("reset_player"):
        player.reset_player()

    player_respawned.emit()

## Andere Entities löschen oder deaktivieren
func _kill_entity(entity: Node) -> void:
    print("Killing entity: %s" % entity.name)

    # Wenn DeathComponent vorhanden, nutze Death-Sequenz
    if entity.has_node("DeathComponent"):
        var death_comp = entity.get_node("DeathComponent")
        death_comp.handle_death()
    else:
        # Sonst direkt löschen
        entity.queue_free()

## Position wo Entities respawnen
func set_respawn_position(pos: Vector2) -> void:
    respawn_position = pos

func get_respawn_position() -> Vector2:
    return respawn_position
