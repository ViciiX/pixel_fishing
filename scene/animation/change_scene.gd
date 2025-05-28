extends ColorRect
var time = 0.5
var wait_time = 0
var call_func = null

signal complete

func _ready() -> void:
	var tween = create_tween()
	modulate.a = 0
	tween.tween_property(self,"modulate:a", 1, time)
	if call != null:
		tween.tween_callback(call_func).set_delay(wait_time)
	tween.tween_property(self,"modulate:a", 0, time)
	tween.tween_callback(func(): complete.emit(self))
