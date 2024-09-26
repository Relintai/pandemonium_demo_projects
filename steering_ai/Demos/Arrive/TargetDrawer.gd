extends Node2D

var deceleration_radius_color : Color = Color(1.0, 0.419, 0.592, 0.5)
var arrival_tolerance_color : Color = Color(0.278, 0.231, 0.47, 0.3)

var arriver: Node2D


func _ready() -> void:
	yield(owner, "ready")
	arriver = owner.arriver


func _draw():
	var target_position := GSAIUtils.to_vector2(arriver.target.position)
	draw_circle(target_position, owner.deceleration_radius, deceleration_radius_color)
	draw_circle(target_position, owner.arrival_tolerance, arrival_tolerance_color)
