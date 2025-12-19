extends Node
class_name IntentEmitter

## Einzige Stelle mit Input-Handling
## Konvertiert Eingabe in abstrakte Intents
## Spieler oder AI können diese Methode auch direkt aufrufen

func collect() -> Array[Intent]:
	var intents: Array[Intent] = []

	# Bewegung
	var move_vec = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if move_vec.length() > 0.0:
		intents.append(Intent.new(Intent.Type.MOVE, move_vec))

	# Interaktion
	if Input.is_action_just_pressed("ui_accept"):
		intents.append(Intent.new(Intent.Type.INTERACT))

	# Abbruch
	if Input.is_action_just_pressed("ui_cancel"):
		intents.append(Intent.new(Intent.Type.CANCEL))

	return intents
