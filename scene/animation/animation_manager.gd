extends Node
var animations = {}
var logger = Logger.new("Animation")
var process_list = Array()

func scan():
	var dir = DirAccess.open("res://scene/animation/")
	for file_name in dir.get_files():
		if file_name.ends_with(".tscn"):
			logger.normal(file_name.substr(0,file_name.length()-5))
			animations[file_name.substr(0,file_name.length()-5)] = load("res://scene/animation/"+file_name)

func new(anim_name: String, args: Dictionary, parent_node: Node, async := false):
	if anim_name in animations.keys():
		var anim_node = animations[anim_name].instantiate()
		for key in args.keys():
			Util.set_recursive(anim_node,key,args[key])
		anim_node.complete.connect(_animation_completed)
		if async:
			parent_node.add_child(anim_node)
		else:
			if process_list.size() == 0:
				parent_node.add_child(anim_node)
			process_list.push_back([anim_node,parent_node])

func _animation_completed(node: Node):
	if process_list.size() > 0:
		process_list.remove_at(0)
	node.queue_free()
	if process_list.size() > 0:
		process_list[0][1].add_child(process_list[0][0])
