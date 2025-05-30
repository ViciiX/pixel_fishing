extends Control

func _ready() -> void:
	set_physics_process(false)

func start():
	visible = true
	$mr_green.size = Vector2(1,8)
	$pointer.position = Vector2(0,-4)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var timer: Timer = $"../throw_timer"
	var percent = (timer.wait_time - timer.time_left) / timer.wait_time
	$mr_green.size = Vector2(int(54*percent),8)
	$pointer.position = Vector2(int(52*percent),-4)
