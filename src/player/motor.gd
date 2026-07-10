extends Node
class_name Motor

## Motion/Animation Controller - beobachtet StateFlags und steuert AnimationPlayer2D
## "Motor" = Motion Engine für Animation & Sound
## Der Motor kümmert sich um:
## - Welche Animation läuft
## - AnimationPlayer2D Trigger
## - AnimatedSprite2D Richtung/Flip
## - Sound-Effekte synchron mit Animationen
## - Andere Attribute (Partikel, etc.)

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var state: StateFlags = $"../StateFlags"

var body: CharacterBody2D
var current_animation: String = "idle"

func setup(p_body: CharacterBody2D):
    body = p_body

func _physics_process(delta: float):
    ## Beobachte StateFlags und bestimme Animation
    update_animation()
    update_sprite_direction()

## ===== ANIMATION LOGIC =====

func update_animation():
    # Bestimmt die aktuelle Animation basierend auf StateFlags und Physics
    var target_anim = _get_target_animation()

    if target_anim != current_animation:
        _transition_to(target_anim)

func _get_target_animation() -> String:
    # Bestimmt welche Animation laufen soll
    # Controlled (auf Chair, im Auto, etc.)
    if state.controlled:
        return "sit" # Placeholder

    # Nicht am Leben
    if not state.alive:
        return "dead"

    # In der Luft
    if not state.grounded:
        # Fällt oder springt?
        if body.velocity.y > 0:
            return "fall"
        else:
            return "jump"

    # Am Boden - Bewegung oder Idle?
    if abs(body.velocity.x) > 0.1:
        return "run"

    return "idle"

func _transition_to(anim_name: String):
    # Wechselt zur neuer Animation
    if not animation_player.has_animation(anim_name):
        print("⚠️ Animation '%s' nicht vorhanden!" % anim_name)
        return

    print("▶️ Motion: %s" % anim_name)
    current_animation = anim_name
    animation_player.play(anim_name)

## ===== SPRITE DIRECTION =====

func update_sprite_direction():
    # Flipped Sprite basierend auf Bewegungsrichtung
    if abs(body.velocity.x) > 0.1:
        animated_sprite.flip_h = body.velocity.x < 0

## ===== SOUND EFFECTS (über AnimationPlayer Callbacks) =====

func _on_animation_finished(anim_name: String):
    # Wird vom AnimationPlayer aufgerufen wenn Animation fertig
    match anim_name:
        "jump":
            play_sound("jump")
        "land":
            play_sound("land")
        "drink":
            play_sound("drink")

func play_sound(sound_name: String):
    # Spiele einen Sound ab
    # TODO: AudioStreamPlayer2D Integration
    print("🔊 Sound: %s" % sound_name)

## ===== PUBLIC API =====

func trigger_animation(anim_name: String):
    # Force-Trigger eine Animation (z.B. von Puppeteer)
    if animation_player.has_animation(anim_name):
        _transition_to(anim_name)
