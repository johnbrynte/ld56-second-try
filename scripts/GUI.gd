extends CanvasLayer

class_name GUI

func set_progress(value: float) -> void:
	$ProgressMarginContainer/PanelContainer/VBoxContainer/ProgressBar.value = value
