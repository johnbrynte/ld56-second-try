extends Node2D

class_name Apple

@onready var holeScene = preload("res://scenes/Hole.tscn")
@onready var fleshHoleScene = preload("res://scenes/FleshHole.tscn")

var countInside = 0
var isInside = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _place_flesh_hole(worm: Worm) -> void:
	var hole = fleshHoleScene.instantiate()
	$Flesh.add_child(hole)
	hole.global_position = worm.targetPosition


func _place_hole(worm: Worm, ingoing: bool) -> void:
	var hole = holeScene.instantiate()
	$Holes.add_child(hole)
	hole.global_position = worm.targetPosition if ingoing else worm.targetPosition - worm.direction * Worm.BODY_SIZE
	if worm.direction.x != 0:
		hole.set_vertical()
	else:
		hole.set_horizontal()


func _on_area_2d_area_exited(area:Area2D) -> void:
	if area.is_in_group("worm"):
		var ball = area as Ball
		ball.set_apple(null)
		countInside -= 1

		if ball.is_head():
			_place_hole(ball.worm, false)

			for body in ball.worm.bodyParts:
				body.z_index = -1

			$Outside/AnimationPlayer.play("fade_in")
			$Holes/AnimationPlayer.play("fade_in")

		ball.z_index = 0
		var previousBall = ball.worm.get_previous_body(ball)
		if previousBall:
			previousBall.z_index = 0

		if isInside and countInside == 0:
			isInside = false


func _on_area_2d_area_entered(area:Area2D) -> void:
	if area.is_in_group("worm"):
		var ball = area as Ball
		ball.set_apple(self)
		countInside += 1

		if ball.is_head():
			_place_hole(ball.worm, true)

			for body in ball.worm.bodyParts:
				body.z_index = 0
			
			$Outside/AnimationPlayer.play("fade_out")
			$Holes/AnimationPlayer.play("fade_out")

		if not isInside and countInside > 0:
			isInside = true


func eat_flesh(ball: Ball) -> void:
	_place_flesh_hole(ball.worm)
