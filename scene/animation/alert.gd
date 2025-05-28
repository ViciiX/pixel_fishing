extends Node

var wait_time = 0.1
var parent: PackedScene

signal complete

func _ready():
	var tween = get_tree().create_tween()
	
