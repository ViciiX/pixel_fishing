extends Node2D
var game_state = GlobalConst.GAME_STATE.MENU
@export var fisherman_scene:PackedScene
@export var anim_change_scene:PackedScene
@export var anim_popup:PackedScene
@export var change_skin_scene:PackedScene
var logger = Logger.new("Main")

func _ready():
	init()
	move_skins()
	add_child(fisherman_scene.instantiate())
	$Fisherman.set_activiate(false)
	logger.normal("----初始化完成----")

func _process(delta):
	pass

func init():
	Logger.setup()
	AnimationManager.scan()
	var dir = DirAccess.open("user://")
	if dir.dir_exists("fisherman") == false:
		dir.make_dir("fisherman")
	if dir.dir_exists("game_log") == false:
		dir.make_dir("game_log")

func game_start():
	game_state = GlobalConst.GAME_STATE.START
	$Fisherman.set_activiate(true)


func _on_seaside_change_skin() -> void:
	$Fisherman.set_physics_process(false)
	$Fisherman/Anima.stop()
	var f = func():
		var ff = func():
			$Fisherman.visible = false
			$seaside.visible = false
			add_child(change_skin_scene.instantiate())
			$change_skin.back.connect(_on_change_skin_back)
			$Fisherman.position = Vector2(128,210)
		AnimationManager.new("change_scene", { "call_func": ff }, self)
	f.call_deferred()
	
func _on_change_skin_back() -> void:
	var f = func():
		var ff = func():
			$Fisherman.set_activiate(true)
			$seaside.visible = true
			$change_skin.queue_free()
		AnimationManager.new("change_scene", { "call_func": ff }, self)
	f.call_deferred()

func move_skins():
	var dir = DirAccess.open("res://src/fisherman/")
	var files = dir.get_files()
	if files.size() > 0:
		for file_name in files:
			Util.unzip("res://src/fisherman/"+file_name,"user://fisherman")
			logger.normal("已解压原生皮肤："+file_name)
			#dir.remove(file_name)
