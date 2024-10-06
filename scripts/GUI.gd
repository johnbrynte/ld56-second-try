extends CanvasLayer

class_name GUI

func _ready() -> void:
	set_text("")


func set_progress(value: float) -> void:
	$ProgressMarginContainer/PanelContainer/VBoxContainer/ProgressBar.value = value


func set_text(text: String) -> void:
	$TextMarginContainer/PanelContainer.visible = text != ""
	$TextMarginContainer/PanelContainer/Label.text = text
