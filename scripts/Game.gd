extends Node2D

@onready var gui: GUI = $GUI

func _ready() -> void:
	$Worm.init(gui)
