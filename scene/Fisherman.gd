"""
@brief 渔夫，即玩家

@var speed 移动速度
@var is_moving 玩家是否在移动
@var is_holding 玩家是否在蓄力扔竿
@var is_hooked 鱼是否在咬钩状态
@var anima 玩家正在执行的走路动画
@var direction 玩家走路/面向的方向
@var state 玩家的状态
- move: 移动
- fishing 钓鱼
@var skin 玩家当前皮肤名
@var skin_config 皮肤配置信息
@var fishing_rod 钓竿品质
@var skin_list 可用的皮肤列表，由scan_skins()更改

@signal fish_hook 玩家取消钓鱼时发出（即放下鱼钩后拿起）
"""

extends CharacterBody2D
@export var speed = 60
var is_moving: bool = false
var is_holding: bool = false
var is_hooked: bool = false
var logger = Logger.new("Fisherman")
var anima = "down"
var direction = "down"
var state = "move"
var skin = "shibalnu"
var skin_config
var fishing_rod = "wooden"
var skin_list = {}

signal lift_hook

func _ready():
	scan_skins()
	load_skin()
	position = Vector2(128,210)
	$Anima.animation = "down_static"
	$Anima.play()

func scan_skins():
	"""
	@brief: 扫描皮肤并添加到皮肤列表
	"""
	logger.normal("开始扫描皮肤")
	skin_list = {}
	var count = 0
	var dir = DirAccess.open("res://src/fisherman") #自带皮肤
	for sname in dir.get_directories():
		skin_list[sname] = "res://src/fisherman/%s/" % sname
		count += 1
	logger.normal("原生皮肤扫描完毕，共%s个" % count)
	count = 0
	dir = DirAccess.open("user://fisherman") #自定义皮肤
	for sname in dir.get_directories():
		skin_list[sname] = "user://fisherman/%s/" % sname
		count += 1
	logger.normal("自定义皮肤扫描完毕，共%s个" % count)
	return skin_list

func load_skin(sname = skin):
	"""
	@brief: 加载指定皮肤并显示
	@param: sname 皮肤名
	"""
	var log_i = []
	logger.normal("开始加载皮肤：%s" % sname)
	var spath = skin_list.get(sname,"")
	if (spath == ""):
		logger.error("未找到皮肤")
		return ERR_FILE_NOT_FOUND
	
	#加载皮肤配置文件
	var config = JSON.new()
	var content = Util.load_file("%sconfig.json" % spath)
	if (typeof(content) == TYPE_BOOL):
		logger.warn("未找到皮肤配置文件,已用空白替代")
		content = "{}"
	var error = config.parse(content)
	
	var img
	if (FileAccess.file_exists(spath + "down_1.png")):
		img = Image.load_from_file(spath + "down_1.png")
	else:
		img = Image.load_from_file(spath + "down_static.png")
	
	var crect = img.get_used_rect()
	var isChanged = false
	if (error == OK):
		#设置碰撞大小与纹理偏移校准
		var vec = config.data.get("collision_size",Array())
		if (vec.size() == 0):
			logger.normal("未找到碰撞大小，已自动生成")
			vec = [crect.size.x,crect.size.y]
			config.data["collision_size"] = vec
			isChanged = true
		$Collision.shape.size = Vector2(vec[0],vec[1])
		vec = config.data.get("offset",Array())
		if (vec.size() == 0):
			logger.normal("未找到纹理偏移校准，已自动生成")
			vec = [-(crect.position.x + crect.size.x / 2), -(crect.position.y + crect.size.y / 2)]
			config.data["offset"] = vec
			isChanged = true
		$Anima.offset = Vector2(vec[0],vec[1])
		
		#导入纹理
		var frame = $Anima.sprite_frames
		for fname in frame.get_animation_names():
			frame.clear(fname)
			if (fname.ends_with("_static")):
				log_i.append(fname)
				if (FileAccess.file_exists("%s%s.png" % [spath,fname])):
					frame.add_frame(fname,Util.load_to_texture("{path}{name}.png".format({"path": spath, "name": fname})))
				else:
					frame.add_frame(fname,Util.load_to_texture("{path}{name}.png".format({"path": spath, "name": fname.replace("static","1")})))
			elif (fname.ends_with("_f")):
				log_i.append(fname)
				frame.add_frame(fname,Util.load_to_texture("%s%s.png" % [spath,fname]))
			elif (fname == "up" or fname == "down"):
				log_i.append(fname)
				if (config.data.get("vertical_fps",-1) > 0):
					frame.set_animation_speed(fname,config.data.get("vertical_fps"))
				var i = 2
				if (FileAccess.file_exists("%s%s_static.png" % [spath,fname])):
					i = 1
				while true:
					var texture_path = "%s%s_%s.png" % [spath,fname,i]
					if (FileAccess.file_exists(texture_path)):
						frame.add_frame(fname,Util.load_to_texture(texture_path))
						i += 1
					else:
						break
			elif (fname == "side"):
				log_i.append(fname)
				if (config.data.get("side_fps",-1) > 0):
					frame.set_animation_speed(fname,config.data.get("side_fps"))
				var i = 1
				while true:
					var texture_path = "%s%s_%s.png" % [spath,fname,i]
					if (FileAccess.file_exists(texture_path)):
						frame.add_frame(fname,Util.load_to_texture(texture_path))
						i += 1
					else:
						break
		if (isChanged):
			Util.save_file("%sconfig.json" % spath, JSON.stringify(config.data, "\t"))
		skin_config = config
	else:
		logger.error("解析皮肤配置信息时出现错误，错误码：%s" % error)
	logger.normal("已加载皮肤动画： {a}".format({"a":", ".join(log_i)}))

func _physics_process(delta):
	if (state == "move"):
		move_process(delta)
	elif (state == "fishing"):
		if (is_holding):
			#蓄力时颤抖
			shake(1.0)
	if (visible == true):
		fishing_process()

func fishing_process():
	if (state == "move" and is_moving == false and $"../seaside".is_can_fishing):
		if (Input.is_action_just_pressed("fishing")):
			if (detect_direction(direction)):
				is_holding = true
				state = "fishing"
				$throw_timer.start()
				$Anima.set_animation("{anima}_{fr}_f".format({"anima":anima, "fr":fishing_rod}))
				$Anima.play()
				$power_bar.start()
	elif (state == "fishing"):
		#释放鱼钩
		if (Input.is_action_just_released("fishing") and is_holding):
			if (detect_direction(direction)):
				is_holding = false
				$fishing_string.visible = true
				var percent = ($throw_timer.wait_time - $throw_timer.time_left)/$throw_timer.wait_time #蓄力程度
				var distance = GlobalConst.FISHING_DISTANCE[fishing_rod] * percent + 10
				var time = distance/(200*(percent+0.5))
				$throw_timer.stop()
				$fishing_string.move_to(get_local_mouse_position(), time, distance)
				$power_bar.visible = false
				$Anima.position = Vector2(0,0)
				
				$fishing_timer.wait_time = randi_range(5, 10)* (1-GlobalConst.FISHING_TIME[fishing_rod])
				$fishing_timer.start()
			else:
				$fishing_string.visible = false
				$fishing_string/buoy.visible = false
				state = "move"
				$power_bar.visible = false
		#取消钓鱼动画
		if (Input.is_action_just_pressed("fishing")):
			lift_hook.emit()

func move_process(delta):
	is_moving = false
	if (Input.is_action_pressed("move_up")):
		move_and_collide(Vector2(0,0-speed*delta))
		if (!is_moving):
			anima = "up"
			direction = "up"
			$Anima.flip_h = false
			if (!$Anima.is_playing()):
				$Anima.set_frame(1)
		is_moving = true
	
	if (Input.is_action_pressed("move_down")):
		move_and_collide(Vector2(0,speed*delta))
		if (!is_moving):
			anima = "down"
			direction = "down"
			$Anima.flip_h = false
			if (!$Anima.is_playing()):
				$Anima.set_frame(1)
		is_moving = true
	
	if (Input.is_action_pressed("move_left")):
		move_and_collide(Vector2(0-speed*delta,0))
		if (!is_moving):
			anima = "side"
			direction = "left"
			$Anima.flip_h = false
			if (!$Anima.is_playing()):
				$Anima.set_frame(1)
		is_moving = true
	
	if (Input.is_action_pressed("move_right")):
		move_and_collide(Vector2(speed*delta,0))
		if (!is_moving):
			anima = "side"
			direction = "right"
			$Anima.flip_h = true
		is_moving = true
	if (is_moving == true):
		$Anima.animation = anima
		$Anima.play()
	else:
		if (anima.ends_with("f") == false):
			$Anima.set_animation("%s_static" % anima)
			$Anima.stop()

func shake(strength):
	$Anima.position = Vector2(randf_range(-strength,strength),randf_range(-strength,strength))

func detect_direction(direction):
	var mouse_pos = get_global_mouse_position()
	var cond = {
	"up": mouse_pos.y < position.y,
	"down": mouse_pos.y > position.y,
	"left": mouse_pos.x < position.x,
	"right": mouse_pos.x > position.x
	}
	return direction in cond and cond[direction]

func cancel_fishing():
	$fishing_string.visible = false
	$fishing_string/buoy.visible = false
	$power_bar.visible = false
	state = "move"
	if (is_hooked):
		print(123)
		AnimationManager.stop("fish_hooked_alert")

func set_activiate(enable:bool):
	visible = enable
	set_physics_process(enable)

func fish_hooked():
	var catch_time = randf_range(0.5, 1)
	var alert = AnimationManager.new("alert", {wait_time = catch_time}, self, "fish_hooked_alert")
	is_hooked = true
	var tween = get_tree().create_tween()
	tween.tween_callback(func(): is_hooked = false).set_delay(catch_time)
