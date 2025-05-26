extends Node2D
signal change_skin
var is_can_fishing = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_change_skin_area_entered(area: Area2D) -> void:
	if area.name == "Fisherman":
		emit_signal("change_skin")

func _on_fishing_place_mouse_entered() -> void:
	is_can_fishing = true

func _on_fishing_place_mouse_exited() -> void:
	is_can_fishing = false
