"""
@brief 感叹号图标的动画
@var wait_time 动画持续时间
@var is_shake 出现时人物是否颤抖
"""

extends Node2D

var wait_time = 0.3
var is_shake = true
var parent
var shake_tween

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
	shake_tween = get_tree().create_tween().set_loops()
	shake_tween.tween_callback(parent.shake.bind(1.0)).set_delay(0.01)
	tween.tween_interval(wait_time)
	tween.tween_callback(stop)

func stop():
	complete.emit(self)
	shake_tween.kill()
	parent.shake(0)
