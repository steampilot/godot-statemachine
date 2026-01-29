extends Node
class_name PlayerPortalSupport

## Portal-Support-Komponente für Player
## Ermöglicht Portal-Puppeteering und Clipping-Effekte

## Portal-Clipping Manager
var _clipping: PortalClipping

## Puppet-Manager
var _puppet_mgr: PuppetManager

## Parent-Player
var _player: Node2D


func _ready() -> void:
    _player = get_parent()

    # Initialisiere Sub-Manager
    _clipping = PortalClipping.new()
    _clipping.name = "PortalClipping"
    add_child(_clipping)

    _puppet_mgr = PuppetManager.new()
    _puppet_mgr.name = "PuppetManager"
    add_child(_puppet_mgr)


func _process(_delta: float) -> void:
    # Update Clipping basierend auf aktuelle Position
    if _clipping and _clipping._clipping_active:
        _clipping._apply_cpu_clipping()


## Aktiviere Portal-Clipping
func set_portal_clipping(portal_pos: Vector2, direction: String) -> void:
    if _clipping:
        _clipping.enable_clipping(portal_pos, direction)


## Deaktiviere Portal-Clipping
func set_clipping_disabled() -> void:
    if _clipping:
        _clipping.disable_clipping()


## Setze Puppeteering-Status
func set_puppeteered(active: bool, puppeteer_obj: Object) -> void:
    if _puppet_mgr:
        _puppet_mgr.set_puppeteered(active, puppeteer_obj)


## Spiegele Intent vom Original-Player
func mirror_intent(original_player: Node2D) -> void:
    if _puppet_mgr:
        _puppet_mgr.mirror_intent(original_player)


## Ist dieser Player gerade ein Puppet?
func is_puppeteered() -> bool:
    return _puppet_mgr and _puppet_mgr.is_puppeteered()


## Gib Puppet-Manager zurück
func get_puppet_manager() -> PuppetManager:
    return _puppet_mgr


## Gib Clipping-Manager zurück
func get_clipping_manager() -> PortalClipping:
    return _clipping
