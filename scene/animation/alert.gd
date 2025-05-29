"""
@brief 感叹号图标的动画
@var wait_time 动画持续时间
"""

extends Node2D

var wait_time = 0.3
var parent

signal complete

func _ready():
	parent = self.get_parent()
	#获取渔夫当前图像
	var anima = parent.get_node("Anima")
	var img = anima.sprite_frames.get_frame_texture(anima.animation, anima.frame).get_image()
	var rect = img.get_used_rect()
	#取图像右上角位置
	var pos = Vector2(rect.position) + anima.offset + Vector2(rect.size.x, 0)
	#加上图像大小1/5的间隔
	pos += Vector2(rect.size)/5
	position = pos
	var tween = get_tree().create_tween()
	tween.tween_interval(wait_time)
	tween.tween_callback(func(): complete.emit(self))
	
