extends Area2D

class_name Ball

var worm: Worm
var apple: Apple


func init(_worm: Worm) -> void:
	worm = _worm


func is_head():
	return worm.get_head() == self


func set_apple(_apple):
	apple = _apple

	eat_apple()


func eat_apple():
	if is_inside_apple():
		apple.eat_flesh(self)


func is_inside_apple():
	return apple != null
