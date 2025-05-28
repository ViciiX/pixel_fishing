extends Node2D
@onready var fisherman = get_parent().get_node("Fisherman")
signal back
var select_list = Array()
var show_list = Array()

func _ready() -> void:
	fisherman.scan_skins()
	select_list = fisherman.skin_list.keys()
	reload()

func _process(delta: float) -> void:
	if Input.is_action_pressed("left_key"):
		if select_list.back() != null and $change_timer.time_left == 0:
			select_list.push_front(select_list.pop_back())
			reload()
			$change_timer.start()

	if Input.is_action_pressed("right_key") and $change_timer.time_left == 0:
		if select_list.size() > 1 and select_list[1] != null:
			select_list.push_back(select_list.pop_front())
			reload()
			$change_timer.start()

	if Input.is_action_pressed("up_key"):
		if $change_timer.time_left == 0:
			show_list.push_front(show_list.pop_back())
			$Control/center_sprite.texture = Util.load_to_texture(fisherman.skin_list[select_list[0]] + show_list[0])
			$change_timer.start()
			
	if Input.is_action_pressed("down_key"):
		if show_list.size() > 1 and show_list[1] != null and $change_timer.time_left == 0:
			show_list.push_back(show_list.pop_front())
			$Control/center_sprite.texture = Util.load_to_texture(fisherman.skin_list[select_list[0]] + show_list[0])
			$change_timer.start()

	if Input.is_action_just_pressed("select"):
		fisherman.skin = select_list[0]
		fisherman.load_skin()
		fisherman.get_node("fishing_string").locate()
		emit_signal("back")

	if Input.is_action_just_pressed("back"):
		emit_signal("back")

func reload():
	if select_list.size() < 1:
		get_parent().move_skins()
		fisherman.scan_skins()
		AnimationManager.new("popup",{
			"content": "皮肤一个都没了！\n已解压自带皮肤",
			"wait_time": 1,
			"bgcolor": Color(Color.DIM_GRAY,0.7),
			"font_size": 16
		}, $Control)
	for n in fisherman.skin_list.keys():
		if select_list.has(n) == false:
			select_list.push_back(n)
	if select_list.size() < 3:
		select_list.resize(3)
	show_skin.call(-1, $Control/left_sprite)
	show_skin.call(0, $Control/center_sprite)
	show_skin.call(1, $Control/right_sprite)
	$Control/skin_name.text = Util.get_value_from_config(fisherman.skin_list[select_list[0]]+"config.json", "name", "未命名皮肤")
	$Control/author_name.text = "作者:"+Util.get_value_from_config(fisherman.skin_list[select_list[0]]+"config.json", "author", "未知")
	var dir = DirAccess.open(fisherman.skin_list[select_list[0]])
	show_list = Array(dir.get_files()).filter(func(file_name): return file_name.ends_with(".png"))

func show_skin(index,node):
		if select_list[index] == null:
			node.visible = false
		else:
			node.visible = true
			var path = fisherman.skin_list[select_list[index]]
			if FileAccess.file_exists(path+"down_1.png"):
				node.texture = Util.load_to_texture(path+"down_1.png")
			else:
				node.texture = Util.load_to_texture(path+"down_static.png")	


func _on_import_button_pressed() -> void:
	$Control/import_button/FileDialog.title = "选择皮肤"
	$Control/import_button/FileDialog.visible = true


func import_skin(path: String) -> void:
	var zip = ZIPReader.new()
	zip.open(path)
	if Array(zip.get_files()).filter(func(file_name): return file_name.ends_with("/")).size() == 1 and zip.get_files()[0].ends_with("/"):
		Util.unzip(path,"user://fisherman/")
		fisherman.scan_skins()
		reload()
	else:
		AnimationManager.new("popup",{
		"content": "皮肤文件无效！\n应压缩包含所有皮肤\n图片的单个文件夹",
		"wait_time": 1,
		"bgcolor": Color(Color.DIM_GRAY,0.7)
		},$Control)

func delete_skin() -> void:
	var path = fisherman.skin_list[select_list[0]]
	OS.move_to_trash(ProjectSettings.globalize_path(path))
	fisherman.scan_skins()
	select_list.pop_front()
	while select_list.size() > 0 and select_list[0] == null:
		select_list.pop_front()
	AnimationManager.new("popup",{
		"content": "删除成功！\n已将皮肤转移到回收站\n(如果有的话)",
		"wait_time": 1,
		"bgcolor": Color(Color.DIM_GRAY,0.7),
		"font_size": 16
		},$Control)
	reload()
