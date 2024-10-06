extends Area2D

class_name Ball

var worm: Worm
var apple: Apple
var direction = Vector2.RIGHT


func init(_worm: Worm, _direction: Vector2) -> void:
	worm = _worm
	direction = _direction

	_update_sprite()


func _update_sprite():
	$Ball.visible = false
	$Head.visible = false
	$End.visible = false

	var sprite = $Ball
	if worm.get_head() == self:
		sprite = $Head
	elif worm.get_end() == self:
		sprite = $End
	sprite.visible = true

	if direction.x < 0:
		sprite.rotation = PI
	elif direction.x > 0:
		sprite.rotation = 0
	elif direction.y < 0:
		sprite.rotation = PI * 3.0 / 2.0
	elif direction.y > 0:
		sprite.rotation = PI / 2.0


func is_head():
	return worm.get_head() == self


func set_direction(dir: Vector2):
	direction = dir
	_update_sprite()


func set_apple(_apple):
	apple = _apple


func eat_apple():
	if is_inside_apple():
		apple.eat_flesh(self)


func is_inside_apple():
	return apple != null
