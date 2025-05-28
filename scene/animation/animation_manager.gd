"""
动画管理器
用于对弹窗等动画的生成、销毁进行管理

对于每个动画的脚本：
都应具有一个[complete]信号，并在动画结束后发送，使得动画管理器可以进行销毁和处理
"""

extends Node
var animations = {}
var logger = Logger.new("Animation")
var process_list = Array()

func scan():
	"""
	@brief 扫描动画并加入到动画列表
	"""
	var dir = DirAccess.open("res://scene/animation/")
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			logger.normal("加载动画："+file_name.substr(0,file_name.length()-5))
			animations[file_name.substr(0,file_name.length()-5)] = load("res://scene/animation/"+file_name)

func new(anim_name: String, args: Dictionary, parent_node: Node, is_direct := false):
	"""
	@brief 新建一个动画
	@param anim_name 动画名称，扫描的文件名
	@param args 对于动画要传入的数
	@param parent_node 动画添加到的父节点
	@param is_direct 是否直接添加（否的话将一个一个执行）
	"""
	if anim_name in animations.keys():
		var anim_node = animations[anim_name].instantiate()
		for key in args.keys():
			Util.set_recursive(anim_node,key,args[key])
		if is_direct:
			anim_node.complete.connect(func(): anim_node.queue_free())
			parent_node.add_child(anim_node)
		else:
			anim_node.complete.connect(_animation_completed)
			if process_list.size() == 0:
				parent_node.add_child(anim_node)
			process_list.push_back([anim_node,parent_node])

func _animation_completed(node: Node):
	"""
	@brief 动画束后的回收函数
	"""
	if process_list.size() > 0:
		process_list.remove_at(0)
	node.queue_free()
	if process_list.size() > 0:
		process_list[0][1].add_child(process_list[0][0])
