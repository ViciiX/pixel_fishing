extends Node

func unzip(from,to): #解压缩
	var zip = ZIPReader.new()
	if zip.open(from) != OK:
		return ERR_FILE_BAD_PATH 
	if to[-1] != "/":
		to+="/"
	if DirAccess.dir_exists_absolute(to) != true:
		return ERR_FILE_CANT_OPEN
	for file_name in zip.get_files():
		if file_name.ends_with("/"):
			var dir = DirAccess.open(to)
			if dir.dir_exists(file_name) == false:
				dir.make_dir(file_name)
		else:
			var f = FileAccess.open(to+file_name,FileAccess.WRITE)
			f.store_buffer(zip.read_file(file_name))
			f.close()
	return OK

func make_dirs(path):
	if (path[-1] != "/"):
		path = "/".join(path.split("/").slice(0, -1))
	DirAccess.make_dir_recursive_absolute(path)

func save_file(path,content): #保存文本文件
	make_dirs(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

func add_file(path,content,new_line=true): #文本文件追加内容
	make_dirs(path)
	if new_line:
		content += "\n"
	var file = FileAccess.open(path, FileAccess.READ_WRITE)
	if FileAccess.file_exists(path):
		file.seek_end()
		file.store_string(content)
	else:
		save_file(path,content)

func load_file(path,value=null): #获取文本文件内容
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		if value == null:
			return false
		else:
			return value
	var content = file.get_as_text()
	return content

func get_value_from_config(path,key,default_value = ""): #从配置文件获取值，获取失败时返回默认值
	var content = load_file(path)
	if typeof(content) == TYPE_BOOL:
		return default_value
	else:
		var config = JSON.new()
		config.parse(content)
		return config.data.get(key,default_value)

func load_to_texture(path):#把路径的图片加载为ImageTexture
	return ImageTexture.create_from_image(Image.load_from_file(path))

func set_recursive(node: Object, prop_str: String, value): #根据地址递归设置最后一个键的值
	var props = Array(prop_str.split(":"))
	var property = props.pop_back()
	var rec_node = node
	for prop in props:
		if rec_node == null:
			return null
		rec_node = rec_node.get(prop)
	if typeof(rec_node) == TYPE_OBJECT:
		rec_node.set(property, value)
	else:
		return null

func get_side_frist_pixel(img: Image, side: String): #获取图片某侧开始的第一个像素的坐标
	if side == "up": #从上往下
		for h in range(img.get_height()):
			for w in range(img.get_width()):
				if img.get_pixel(w, h).a != 0:
					return Vector2(w, h)
	elif side == "down":
		for h in range(img.get_height()-1, -1, -1):
			for w in range(img.get_width()):
				if img.get_pixel(w, h).a != 0:
					return Vector2(w, h)
	elif side == "left":
		for w in range(img.get_width()):
			for h in range(img.get_height()):
				if img.get_pixel(w, h).a != 0:
					return Vector2(w, h)
	elif side == "right":
		for w in range(img.get_width()-1, -1, -1):
			for h in range(img.get_height()):
				if img.get_pixel(w, h).a != 0:
					return Vector2(w, h)
	else:
		return 0
