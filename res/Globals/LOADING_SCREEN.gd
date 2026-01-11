extends CanvasLayer

signal gransition_in_complete
# signal transition_out_complete


var starting_animation: String = ""

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var timer: Timer = $Timer


func _ready() -> void:
    set_name("LOADING_SCREEN")
    print("✓ LOADING_SCREEN Singleton initialisiert")
    progress_bar.visible = false

func start_transition(animation_name: String) -> void:
    if !animation_player.has_animation(animation_name):
        push_warning("Animation %s nicht gefunden im LOADING_SCREEN" % animation_name)
        # fallback to default
        animation_name = "fade_to_black"
    starting_animation = animation_name
    animation_player.play(animation_name)
    # if timer reacheds the end befor finished loading we show the progress bar
    timer.start()

func finish_transition() -> void:
    if timer:
        timer.stop()
    var ending_animation_name: String = starting_animation.replace("to", "from")
    if !animation_player.has_animation(ending_animation_name):
        push_warning("Animation %s nicht gefunden im LOADING_SCREEN" % ending_animation_name)
        # fallback to default
        ending_animation_name = "fade_from_black"
    animation_player.play(ending_animation_name)
    await animation_player.animation_finished
    queue_free()

func report_midpoint() -> void:
    gransition_in_complete.emit()


func _on_timer_timeout() -> void:
    progress_bar.visible = true
    timer.stop()
