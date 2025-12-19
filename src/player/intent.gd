class_name Intent

## Abstrakte Absicht - Input-unabhängig
## Wird von IntentEmitter erzeugt oder von AI/Netzwerk

enum Type {
	MOVE,
	INTERACT,
	CANCEL,
	# Game-Level Intents
	LOAD_SCENE,
	PAUSE,
	RESUME
}

var type: Type
var value  # Vector2 für MOVE, String für LOAD_SCENE, null für andere

func _init(t: Type, v = null):
	type = t
	value = v
