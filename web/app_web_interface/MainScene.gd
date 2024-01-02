extends Node

export(NodePath) var color_picker_path

func get_color() -> Color:
	var style_box : StyleBoxFlat = get_node(^"PanelContainer").get_theme_stylebox("panel")
	return style_box.bg_color

func set_color(color : Color):
	var style_box : StyleBoxFlat = get_node(^"PanelContainer").get_theme_stylebox("panel")
	style_box.bg_color = color
	
	get_node(color_picker_path).color = color
