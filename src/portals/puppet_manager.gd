extends Node
class_name PuppetManager

## Puppet-Manager für Portal-System
## Managed die Erstellung und Synchronisation von Puppet-Klonen

## Parent-Entity (der echte Spieler)
var _parent: Node2D

## Ist diese Entity gerade ein Puppet unter Kontrolle?
var _puppeteered: bool = false

## Puppeteer-Referenz (Portal oder andere Controller)
var _puppeteer: Object

## Original-Intent vom echten Player
var _mirrored_intent: Dictionary = {}


func _ready() -> void:
	_parent = get_parent()


## Setze Puppeteering-Status
func set_puppeteered(active: bool, puppeteer_obj: Object) -> void:
	_puppeteered = active
	_puppeteer = puppeteer_obj


## Ist diese Entity ein Puppet?
func is_puppeteered() -> bool:
	return _puppeteered


## Spiegele Intent vom Original-Player
func mirror_intent(original_player: Node2D) -> void:
	if not original_player:
		return

	_mirrored_intent = {
		"facing_direction": original_player.get_meta("facing_direction", 1) if original_player.has_meta("facing_direction") else 1,
		"velocity": original_player.velocity if "velocity" in original_player else Vector2.ZERO,
		"animation_state": original_player.get_meta("animation_state", "idle") if original_player.has_meta("animation_state") else "idle",
		"is_jumping": original_player.get_meta("is_jumping", false) if original_player.has_meta("is_jumping") else false,
	}

	# Appliziere gespiegelte Intent auf dieses Puppet
	_apply_mirrored_intent()


## Appliziere gespiegelte Intent auf Puppet
func _apply_mirrored_intent() -> void:
	if not _parent:
		return

	# Update Facing-Direction
	if "facing_direction" in _mirrored_intent:
		_parent.set_meta("facing_direction", _mirrored_intent["facing_direction"])

	# Update Velocity
	if "velocity" in _mirrored_intent and "velocity" in _parent:
		_parent.velocity = _mirrored_intent["velocity"]

	# Update Animation
	if "animation_state" in _mirrored_intent and _parent.has_method("play_animation"):
		_parent.play_animation(_mirrored_intent["animation_state"])

	# Update Jump-State
	if "is_jumping" in _mirrored_intent:
		_parent.set_meta("is_jumping", _mirrored_intent["is_jumping"])


## Duplicate Player als Puppet-Klon
static func create_puppet_clone(original: Node2D) -> Node2D:
	var puppet = original.duplicate()
	puppet.name = original.name + "_Puppet"

	# Aktiviere Puppet-Manager auf Klon
	if puppet.has_node("PuppetManager"):
		var puppet_mgr = puppet.get_node("PuppetManager")
		puppet_mgr.set_puppeteered(true, null)

	return puppet


## Cleanup Puppet (wird beim Swap aufgerufen)
func cleanup_puppet() -> void:
	if not _parent:
		return

	_puppeteered = false
	_puppeteer = null
	_mirrored_intent.clear()

	# Queue für Deletion
	_parent.queue_free()
