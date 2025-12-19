class_name Intent

## Abstrakte Absicht - Input-unabhängig
## Wird von IntentEmitter erzeugt oder von AI/Netzwerk

enum Type {
	MOVE,
	INTERACT,
	CANCEL
}

var type: Type
var value  # Vector2 für MOVE, null für andere

func _init(t: Type, v = null):
	type = t
	value = v
