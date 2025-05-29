"""
@brief 弹窗动画
@var width 每行所能容纳的文字数量，如果为null则会自动计算
@var mode 
"""

extends Control
var content = ""
var width
var mode = 1 #0:单行模式,1:多行模式
var ratio = Vector2(1,1)
var time = 0.5
var wait_time = 1
var margin = 10
var bg_color = Color.DIM_GRAY
var font_size = 16
var font_color = Color.WHITE

signal complete

func _ready() -> void:
	$text/background/ColorRect.color = bg_color
	$text.label_settings.font_size = font_size
	$text.label_settings.font_color = font_color
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modulate.a = 0
	$text.text = content
	if width == null:
		var arr = Array(content.split("\n"))
		#取文本各行中最长一行的字数
		var filter = func(a,b): return a.length() > b.length()
		var rect_x = arr.reduce(func(a, b): if filter.call(a, b): return a else: return b).length()
		var rect_y = arr.size()
		if mode == 0:
			"""
			设文本单行时所占面积为S, 按比例x,y转换后目标的长和宽为a, b
			设a = x*k, b = y*k,
			则S = a*b = x*y*k*k, 所以 k = sqrt(S/x*y)
			所以a = sqrt(x*S/y), b = sqrt(y*S/x)
			a即为width
			"""
			width = ceil(sqrt((rect_x * rect_y * (font_size ** 2) * ratio.x) / ratio.y))
		else:
			width = rect_x * font_size
	else:
		width *= font_size
	$text.size.x = max(16, width)
	#调整文本和背景的位置和填充等
	$text.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_WIDTH)
	$text/background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, -margin)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, time)
	tween.tween_interval(wait_time)
	tween.tween_property(self, "modulate:a", 0, time)
	tween.tween_callback(func(): complete.emit(self))
	
