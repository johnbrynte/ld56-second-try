extends Node2D

class_name Worm

const BODY_SIZE = 64
const MOVE_SPEED = 0.15
const FALL_SPEED = 0.05
const KEY_REPEAT_TIME = 0.2
const MUNCH_MAX = 40

@export var startApple: Apple

@onready var ballScene = preload("res://scenes/Ball.tscn")

var munchProgress = 0
var timer = 0
var isMoving = false
var isFalling = false
var isDone = false
var direction = Vector2.ONE
var queuedDirection
var keyRepeatTimer = 0
@onready var targetPosition = position
var bodyLength = 2
@onready var bodyParts = [$Head]
var gui: GUI


func init(_gui: GUI) -> void:
	gui = _gui


func _ready() -> void:
	$Head.init(self, direction)
	if startApple:
		startApple.set_ball_apple($Head)

	for i in range(bodyLength):
		_add_body_part(direction)


func _physics_process(delta: float) -> void:
	if isDone:
		return

	timer += delta

	var axis = Vector2(
		-1 if Input.is_action_pressed("left") else 1 if Input.is_action_pressed("right") else 0,
		-1 if Input.is_action_pressed("up") else 1 if Input.is_action_pressed("down") else 0
	)

	if not _get_apple():
		if not isFalling:
			isFalling = true
			gui.set_text("Reset with R / Enter")
		if not isMoving:
			_move_to(Vector2.DOWN)
		return

	if isFalling:
		isFalling = false
		gui.set_text("")

	if axis.x != 0 or axis.y != 0:
		if keyRepeatTimer == 0 or keyRepeatTimer > KEY_REPEAT_TIME:
			direction = axis
			if axis.x != 0 and direction.y != 0:
				direction.y = 0
			_move_to(direction)
		keyRepeatTimer += delta
	else:
		keyRepeatTimer = 0


func _test_direction(dir: Vector2) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		$Head.global_position,
		$Head.global_position + dir * BODY_SIZE,
		int(pow(2, 2-1))
	)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	return result


func _move_to(new_direction: Vector2) -> void:
	if isMoving:
		queuedDirection = new_direction
		return
	
	if _get_apple():
		var result = _test_direction(new_direction)
		if result:
			return
	
	isMoving = true
	queuedDirection = null
	var apple = _get_apple()
	var new_pos = $Head.position + new_direction * BODY_SIZE
	targetPosition = global_position + new_pos
	var speed = MOVE_SPEED if apple else FALL_SPEED
	
	var pos = new_pos
	var new_positions = []
	for body in bodyParts:
		var prev_pos = body.position
		var dir = (pos - prev_pos).normalized()
		body.set_direction(dir)
		new_positions.append(pos)
		pos = prev_pos
	for i in range(len(bodyParts)):
		var tween = get_tree().create_tween()
		tween.tween_property(bodyParts[i], "position", new_positions[i], speed).set_trans(Tween.TRANS_QUART)
	
	await get_tree().create_timer(speed + 0.02).timeout

	isMoving = false

	if not _test_flesh():
		eat_apple()

	if _test_if_stuck():
		print("game over!")
		return

	# if queuedDirection:
	# 	_move_to(queuedDirection)


func _add_body_part(dir: Vector2) -> void:
	var body = ballScene.instantiate()
	body.init(self, dir)
	add_child(body)
	body.position = bodyParts[-1].position
	bodyParts.append(body)


func _get_apple():
	for body in bodyParts:
		if body.is_inside_apple():
			return body.apple
	return null


func _test_if_stuck() -> bool:
	return [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].reduce(
		func (acc, dir) -> bool:
			return acc and _test_direction(dir)
	, true)


func _test_flesh() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.position = $Head.global_position
	query.collision_mask = int(pow(2, 3-1))
	var result = space_state.intersect_point(query)
	return len(result) > 0


func eat_apple() -> void:
	if not $Head.is_inside_apple():
		return
	$Head.eat_apple()
	munchProgress += 1
	if munchProgress >= MUNCH_MAX:
		_add_body_part(direction)
		munchProgress = 0
		gui.set_progress(0)
	else:
		gui.set_progress(100.0 * float(munchProgress) / MUNCH_MAX)


func get_previous_body(ball: Ball) -> Ball:
	var index = bodyParts.find(ball)
	if index == -1:
		return null
	return bodyParts[index + 1] if index < bodyParts.size() - 1 else null


func get_head() -> Ball:
	return $Head


func get_end() -> Ball:
	return bodyParts[-1]


func _on_head_area_entered(area: Area2D) -> void:
	if area.is_in_group("partner"):
		isDone = true
		gui.set_text("You found love in {time} seconds!".format({
			"time": str(int(timer))
		}))
		area.get_node("Heart").visible = true