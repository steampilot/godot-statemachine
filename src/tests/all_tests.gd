extends Node
class_name AllTests

## Master Test Runner - führt alle Tests aus

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("STARTEN ALLE UNIT TESTS")
	print("=".repeat(50) + "\n")

	# Tests ausführen
	run_tests()

	print("\n" + "=".repeat(50))
	print("ALLE TESTS ABGESCHLOSSEN")
	print("=".repeat(50) + "\n")

func run_tests() -> void:
	# Intent Tests
	var intent_test = IntentTest.new()
	add_child(intent_test)
	await get_tree().process_frame

	# GameState Tests
	var state_test = GameStateTest.new()
	add_child(state_test)
	await get_tree().process_frame

	# GameStateMachine Tests
	var state_machine_test = GameStateMachineTest.new()
	add_child(state_machine_test)
	await get_tree().process_frame

	# SceneLoader Tests
	var scene_loader_test = SceneLoaderTest.new()
	add_child(scene_loader_test)
	await get_tree().process_frame
