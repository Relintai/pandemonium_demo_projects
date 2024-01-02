extends Button

export(NodePath) var target_node : NodePath

func _on_ColorSetButton_pressed() -> void:
	var color : Color = get_parent().get_node("ColorPickerButton").color
	
	get_node(target_node).set_color(color)
