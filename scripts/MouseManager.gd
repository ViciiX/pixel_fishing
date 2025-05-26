extends Node2D
var mouse_scale = 1
var last_size
var fishing_mouse = load("res://src/UI/mouse/fishing_mouse.png")

func _ready():
	pass

func _process(delta):
	var window_size = get_tree().root.size
	var size = min(window_size.x,window_size.y)
	if last_size != size:
		last_size = size
		mouse_scale = size/256.0
		var f = fishing_mouse.get_image()
		f.resize(floor(27*mouse_scale),floor(27*mouse_scale),Image.INTERPOLATE_NEAREST)
		if get_parent().game_state == GlobalConst.GAME_STATE.MENU:
			Input.set_custom_mouse_cursor(ImageTexture.create_from_image(f),Input.CURSOR_ARROW,Vector2i(floor(27*mouse_scale),floor(27*mouse_scale)))
			Input.set_custom_mouse_cursor(ImageTexture.create_from_image(f),Input.CURSOR_POINTING_HAND,Vector2i(floor(27*mouse_scale),floor(27*mouse_scale)))
		else:
			Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
			Input.set_custom_mouse_cursor(ImageTexture.create_from_image(f),Input.CURSOR_POINTING_HAND,Vector2i(floor(27*mouse_scale),floor(27*mouse_scale)))


func game_start():
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	
