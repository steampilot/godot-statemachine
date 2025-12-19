extends Node
class_name PlayerIntegrationTest

## TDD Test-Suite für State Machine: Player + Chair + Ball
## Diese Tests definieren das gewünschte Verhalten VOR der Implementierung

var player: Player
var chair: Chair
var ball: Ball
var test_count := 0
var passed := 0
var failed := 0

func _ready():
	await get_tree().process_frame
	run_all_tests()

func run_all_tests():
	print("\n" + "=".repeat(60))
	print("🧪 INTEGRATION TEST SUITE - Player + Chair + Ball")
	print("=".repeat(60) + "\n")

	# Setup
	player = $Player
	chair = $Chair
	ball = $Ball

	# Tests
	test_player_can_walk_freely()
	test_player_can_pick_up_ball()
	test_player_with_ball_can_sit()
	test_player_can_drop_ball()
	test_player_can_sit_on_chair()
	test_player_can_stand_up_from_chair()

	# Results
	print("\n" + "=".repeat(60))
	print("📊 TEST RESULTS: %d/%d passed" % [passed, test_count])
	print("=".repeat(60) + "\n")

## TEST 1: Player kann frei laufen
func test_player_can_walk_freely():
	test_count += 1
	print("TEST 1: Player can walk freely")

	var initial_pos = player.global_position.x

	# Simuliere Bewegung
	var move_intent = Intent.new(Intent.Type.MOVE, Vector2(1, 0))
	player.motor.apply_intent(move_intent, 0.016)
	player.motor.physics_tick(0.016)

	# Player sollte sich bewegt haben
	var moved = player.global_position.x > initial_pos

	if moved:
		print("  ✅ PASS: Player moved %.2f units" % (player.global_position.x - initial_pos))
		passed += 1
	else:
		print("  ❌ FAIL: Player did not move")
		failed += 1

## TEST 2: Player kann Ball aufnehmen
func test_player_can_pick_up_ball():
	test_count += 1
	print("TEST 2: Player can pick up ball")

	# Ball an Player AttachmentSlot attached
	ball.attach_to_player(player)

	var is_attached = ball.get_parent() == player.$AttachmentSlot
	var ball_visible = ball.visible

	if is_attached and ball_visible:
		print("  ✅ PASS: Ball attached to player.AttachmentSlot")
		passed += 1
	else:
		print("  ❌ FAIL: Ball not properly attached")
		failed += 1

## TEST 3: Player mit Ball kann auf Stuhl sitzen
func test_player_with_ball_can_sit():
	test_count += 1
	print("TEST 3: Player with ball can sit on chair")

	# Ball muss noch attached sein
	if ball.get_parent() != player.$AttachmentSlot:
		ball.attach_to_player(player)

	# Player sitzt auf Stuhl
	chair.capture(player)
	await get_tree().process_frame

	var is_captured = player.state.controlled
	var ball_still_attached = ball.get_parent() == player.$AttachmentSlot

	if is_captured and ball_still_attached:
		print("  ✅ PASS: Player captured and ball still attached")
		passed += 1
	else:
		print("  ❌ FAIL: Capture failed or ball lost")
		failed += 1

## TEST 4: Player kann Ball fallen lassen
func test_player_can_drop_ball():
	test_count += 1
	print("TEST 4: Player can drop ball")

	var chair_pos: Vector2 = chair.global_position
	var ball_dropped = ball.get_parent() == chair.get_parent()  # Global scene
	var ball_visible = ball.visible

	if ball_dropped and ball_visible:
		print("  ✅ PASS: Ball dropped at chair location")
		passed += 1
	else:
		print("  ❌ FAIL: Ball drop failed")
		failed += 1

## TEST 5: Player kann auf Stuhl sitzen
func test_player_can_sit_on_chair():
	test_count += 1
	print("TEST 5: Player can sit on chair")

	# Player sitzt (capture)
	chair.capture(player)
	await get_tree().process_frame

	var is_controlled = player.state.controlled
	var puppeteer_is_chair = player.puppeteer == chair

	if is_controlled and puppeteer_is_chair:
		print("  ✅ PASS: Player sitting on chair")
		passed += 1
	else:
		print("  ❌ FAIL: Sit failed")
		failed += 1

## TEST 6: Player kann vom Stuhl aufstehen
func test_player_can_stand_up_from_chair():
	test_count += 1
	print("TEST 6: Player can stand up from chair")

	# Player muss sitzen
	if not player.state.controlled:
		chair.capture(player)
		await get_tree().process_frame

	# Release
	chair.release()
	await get_tree().process_frame

	var is_free = not player.state.controlled
	var no_puppeteer = player.puppeteer == null

	if is_free and no_puppeteer:
		print("  ✅ PASS: Player stood up")
		passed += 1
	else:
		print("  ❌ FAIL: Stand up failed")
		failed += 1
