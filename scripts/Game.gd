extends Node2D

@onready var gui: GUI = $GUI

func _ready() -> void:
	$Worm.init(gui)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
