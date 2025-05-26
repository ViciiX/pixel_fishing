extends Control
var logger = Logger.new("fishing_string")
var fm
var pos = Vector2(0, 0)
var anim_pos = Vector2(0, 0)
var target_pos = Vector2(0, 0)
var mouse_pos = Vector2(0, 0)
var max_time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fm = get_parent()
	set_physics_process(false)
	$buoy.visible = false
	$spray.visible = false

func _draw():
	draw_line(pos, anim_pos, Color.WHITE)

func _physics_process(delta: float):
	if visible:
		if $anim_timer.time_left > 0:
			anim_pos += (target_pos - pos)/(max_time/delta)
			$buoy.position = anim_pos
			queue_redraw()
		else:
			$anim_timer.stop()
			$buoy.scale = Vector2(1,1)
			var areas = $buoy.get_overlapping_areas()
			var is_can_fishing = false
			for area in areas:
				if area.name == "fishing_area":
					is_can_fishing = true
			if !is_can_fishing:
				fm.cancel_fishing()
			else:
				summon_spray($buoy.position-Vector2(8,6))
			set_physics_process(false)

func summon_spray(pos: Vector2):
	$spray.modulate.a = 0.8
	$spray.position = pos
	$spray.visible = true
	var tween = create_tween()
	var anim_tween = create_tween().set_loops()
	var f = func():
		$spray.visible = false
		tween.kill()
		anim_tween.kill()
	var shake = func():
		$spray.flip_h = !$spray.flip_h
	anim_tween.tween_callback(shake).set_delay(0.2)
	tween.tween_property($spray,"modulate:a",0.0,1)
	tween.tween_callback(f)

func move_to(mp: Vector2,  time = 2, distance = -1):
	mouse_pos = mp
	locate()
	anim_pos = pos
	if distance > 0:
		target_pos = anim_pos.move_toward(mouse_pos, distance)
	else:
		target_pos = mouse_pos
	$anim_timer.start(time)
	max_time = time
	$buoy.visible = true
	$buoy.scale = Vector2(1.1,1.1)
	set_physics_process(true)

func locate():
	var img: Image = $"../Anima".sprite_frames.get_frame_texture("{anima}_{fr}_f".format({"anima":fm.anima, "fr":fm.fishing_rod}),0).get_image()
	var cfg = fm.skin_config
	var loc = cfg.data.get("fishing_rod_position",Array())
	if loc.size() == 0:
		if fm.direction == "right":
			img.flip_x()
		pos = Util.get_side_frist_pixel(img, fm.direction)
		pos += $"../Anima".offset
	else:
		pos = loc
	
