extends Node

func unzip(from, to):
	"""
	@brief 解压缩zip文件
	@param from zip文件路径
	@param to 输出目录
	@return ERR_FILE_BAD_PATH | OK
	"""
	var zip = ZIPReader.new()
	if (zip.open(from) != OK):
		return ERR_FILE_BAD_PATH 
	if (to[-1] != "/"):
		to+="/"
	if (DirAccess.dir_exists_absolute(to) != true):
		return ERR_FILE_CANT_OPEN
	for file_name in zip.get_files():
		if (file_name.ends_with("/")):
			var dir = DirAccess.open(to)
			if (dir.dir_exists(file_name) == false):
				dir.make_dir(file_name)
		else:
			var f = FileAccess.open(to+file_name,FileAccess.WRITE)
			f.store_buffer(zip.read_file(file_name))
			f.close()
	return OK

func make_dirs(path):
	"""
	@brief 创建文件的前置文件夹
	@param path 文件路径
	"""
	if (path[-1] != "/"):
		path = "/".join(path.split("/").slice(0, -1))
	DirAccess.make_dir_recursive_absolute(path)

func save_file(path, content):
	"""
	@breif 将内容写入文本文件
	@param path 文件路径
	@param content 内容
	"""
	make_dirs(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

func add_file(path, content, new_line = true):
	"""
	@brief 在文件末尾追加内容
	@param path 文件路径
	@param content 内容
	@param new_line 追加前是否另起一行
	"""
	make_dirs(path)
	if (new_line):
		content += "\n"
	var file = FileAccess.open(path, FileAccess.READ_WRITE)
	if (FileAccess.file_exists(path)):
		file.seek_end()
		file.store_string(content)
	else:
		save_file(path,content)

func load_file(path, value = null):
	"""
	@brief 从文本文件读取内容，获取失败时返回默认值
	@param path 文件路径
	@param value 默认值，读取失败时返回
	@return 获取到的内容 | 默认值 | false
	"""
	var file = FileAccess.open(path, FileAccess.READ)
	if (file == null):
		if (value == null):
			return false
		else:
			return value
	var content = file.get_as_text()
	return content

func get_value_from_config(path, key, default_value = ""): 
	"""
	@brief 以json格式获取值，获取失败时返回默认值
	@param path 文件路径
	@param key 键
	@param default_value 默认值
	@return 获取到的值 | 默认值
	"""
	var content = load_file(path)
	if (typeof(content) == TYPE_BOOL):
		return default_value
	else:
		var config = JSON.new()
		config.parse(content)
		return config.data.get(key,default_value)

func load_to_texture(path):
	"""
	@brief 把路径的图片加载为ImageTexture
	@param path 图片路径
	@return 加载后的ImageTexture
	"""
	return ImageTexture.create_from_image(Image.load_from_file(path))

func set_recursive(node: Object, prop_str: String, value): 
	"""
	@brief 根据给定的一系列属性递归设置最后一个键的值
	@param node 设置的对象
	@param prop_str 设置的属性，以":"分割
	@param value 设置的值
	@return 是否成功
	"""
	var props = Array(prop_str.split(":"))
	var property = props.pop_back()
	var rec_node = node
	for prop in props:
		if (rec_node == null):
			return false
		rec_node = rec_node.get(prop)
	if (typeof(rec_node) == TYPE_OBJECT):
		rec_node.set(property, value)
		return true
	else:
		return false

func get_side_first_pixel(img: Image, side: String): 
	"""
	@brief 获取图片某侧开始的第一个像素的坐标
	@param img 图片
	@param side 从哪侧开始扫描
	@return 像素的坐标
	up; down; left; right
	"""
	if (side == "up"): #从上往下，左上角
		for h in range(img.get_height()):
			for w in range(img.get_width()):
				if (img.get_pixel(w, h).a != 0):
					return Vector2(w, h)
	elif (side == "down"): #从下往上，右下角
		for h in range(img.get_height()-1, -1, -1):
			for w in range(img.get_width()-1, -1, -1):
				if (img.get_pixel(w, h).a != 0):
					return Vector2(w, h)
	elif (side == "left"): #从左往右，左下角
		for w in range(img.get_width()):
			for h in range(img.get_height()-1, -1, -1):
				if (img.get_pixel(w, h).a != 0):
					return Vector2(w, h)
	elif (side == "right"): #从右往左，右上角
		for w in range(img.get_width()-1, -1, -1):
			for h in range(img.get_height()):
				if (img.get_pixel(w, h).a != 0):
					return Vector2(w, h)
	else:
		return Vector2.ZERO
