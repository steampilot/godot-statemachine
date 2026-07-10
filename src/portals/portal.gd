extends Area2D
class_name Portal

## Portal-System für nahtlose Level- und Spawnpoint-Übergänge
## Ein Portal verbindet zwei Räume und ermöglicht Teleportation mit visueller
## Kontinuität durch Puppeteering und Portal-Clipping

signal player_entered_portal
signal player_exited_portal
signal portal_swap_completed

## Verbundenes Portal auf der anderen Seite
@export var paired_portal: Portal

## Eindeutige Portal-ID (für Serialisierung und Debugging)
@export var portal_id: String = ""

## Ziel-Spawnpoint ID beim Ankommen (optional)
@export var target_spawn_point_id: String = ""

## Level zu laden (leer = gleicher Level)
@export var target_level_path: String = ""

## Puppet-Node (wird beim Area-Enter erstellt)
var _puppet: Node2D

## Ist Puppet aktuell aktiv und synchronisiert?
var _puppet_active: bool = false

## Reference zum echten Player
var _player: Node2D

## Ist Player gerade in dieser Portal-Area?
var _player_in_area: bool = false


func _ready() -> void:
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

    if not paired_portal:
        push_warning("Portal '%s': Kein paired_portal gesetzt!" % portal_id)


func _process(_delta: float) -> void:
    # Wenn Player in Area ist: Sync Puppet mit Player
    if _player_in_area and _puppet and _puppet_active:
        _sync_puppet_with_player()


func _on_area_entered(area: Area2D) -> void:
    var player = _get_player_from_area(area)
    if not player:
        return

    _player = player
    _player_in_area = true

    player_entered_portal.emit()

    # Erstelle Puppet am anderen Portal
    _spawn_puppet_at_paired_portal()

    # Aktiviere Portal-Clipping auf Player
    _enable_player_clipping()


func _on_area_exited(area: Area2D) -> void:
    var player = _get_player_from_area(area)
    if not player or player != _player:
        return

    _player_in_area = false

    # Prüfe ob Player die Portal-Grenze in Richtung paired_portal überschreitet
    if _is_crossing_portal(player):
        # SWAP: Player teleportiert zur Puppet-Position
        _perform_portal_swap(player)
    else:
        # Player geht weg von Portal → Cleanup
        _cleanup()

    player_exited_portal.emit()


func _spawn_puppet_at_paired_portal() -> void:
    if not paired_portal or _puppet_active:
        return

    _puppet_active = true

    # Dupliziere Player als Puppet
    _puppet = _player.duplicate()
    _puppet.name = _player.name + "_Puppet"

    # Setze Puppet-Position am anderen Portal
    _puppet.global_position = paired_portal.global_position

    # Aktiviere Puppeteering: Puppet folgt dem Original-Player
    if _puppet.has_method("set_puppeteered"):
        _puppet.set_puppeteered(true, self)

    # Puppet zur Scene des anderen Portals hinzufügen
    paired_portal.add_child(_puppet)

    # Aktiviere Portal-Clipping auf Puppet (andere Seite als Player)
    _enable_puppet_clipping()


func _sync_puppet_with_player() -> void:
    if not _puppet or not _player:
        return

    # Puppet spiegelt Player's Velocity & Animation
    if "velocity" in _player:
        _puppet.velocity = _player.velocity

    # Mirror Intent/Animation-State
    if _puppet.has_method("mirror_intent"):
        _puppet.mirror_intent(_player)

    # Optional: Puppet-Position folgt Player's Y-Achse
    # (X-Position bleibt bei paired_portal für Clipping-Effekt)


func _enable_player_clipping() -> void:
    if not _player or not _player.has_method("set_portal_clipping"):
        return

    # Bestimme Clipping-Richtung basierend auf Portal-Ausrichtung
    var clip_direction = _get_clip_direction_for_player()
    _player.set_portal_clipping(global_position, clip_direction)


func _enable_puppet_clipping() -> void:
    if not _puppet or not _puppet.has_method("set_portal_clipping"):
        return

    # Puppet wird auf der ENTGEGENGESETZTEN Seite des Portals gerendert
    var clip_direction = _get_clip_direction_for_puppet()
    _puppet.set_portal_clipping(paired_portal.global_position, clip_direction)


func _disable_clipping() -> void:
    if _player and _player.has_method("set_clipping_disabled"):
        _player.set_clipping_disabled()
    if _puppet and _puppet.has_method("set_clipping_disabled"):
        _puppet.set_clipping_disabled()


func _get_clip_direction_for_player() -> String:
    # Player wird nur auf DIESER Seite des Portals gerendert
    if paired_portal.global_position.x > global_position.x:
        return "RIGHT" # Player rechts des Portals
    return "LEFT" # Player links des Portals


func _get_clip_direction_for_puppet() -> String:
    # Puppet wird auf der ANDEREN Seite gerendert
    if paired_portal.global_position.x > global_position.x:
        return "LEFT" # Puppet links des Portals
    return "RIGHT" # Puppet rechts des Portals


func _is_crossing_portal(player: Node2D) -> bool:
    # Prüfe: Überschreitet Player gerade die Portal-Grenze
    # in Richtung paired_portal?
    if not ("velocity" in player):
        return false

    var player_velocity = player.velocity
    if player_velocity.length() < 0.1:
        return false

    # Portal-Richtung (von diesem Portal zum paired_portal)
    var portal_direction = (paired_portal.global_position - global_position).normalized()
    var player_direction = player_velocity.normalized()

    # Crossing wenn Bewegungsrichtung ungefähr gleich Portal-Richtung
    var dot_product = player_direction.dot(portal_direction)
    return dot_product > 0.7 # ~45° Toleranz


func _perform_portal_swap(player: Node2D) -> void:
    if not _puppet or not paired_portal:
        return

    # 1. Speichere Puppet's State
    var puppet_pos = _puppet.global_position
    var puppet_velocity = Vector2.ZERO
    if "velocity" in _puppet:
        puppet_velocity = _puppet.velocity

    # 2. Teleportiere echten Player zur Puppet-Position
    player.global_position = puppet_pos
    if "velocity" in player:
        player.velocity = puppet_velocity

    # 3. Emit Signal für Transaktionen
    portal_swap_completed.emit()

    # 4. Cleanup
    _cleanup()

    # 5. Wenn Level-Wechsel: Lade neues Level mit Spawnpoint
    if target_level_path:
        LEVEL_LOADER.load_level(target_level_path, target_spawn_point_id)


func _cleanup() -> void:
    _disable_clipping()
    _deactivate_puppet()
    _player = null
    _player_in_area = false


func _deactivate_puppet() -> void:
    if _puppet:
        _puppet.queue_free()
        _puppet = null
    _puppet_active = false


func _get_player_from_area(area: Area2D) -> Node2D:
    # Extrahiere Player-Node aus verschiedenen möglichen Area-Typen
    if area.name == "PlayerHitbox":
        return area.get_parent()
    if area.is_in_group("player"):
        return area
    return null
