extends Node2D
signal game_started
@onready var tween = get_tree().create_tween()

func _ready():
	$Title.modulate.a = 0
	$StartButton.modulate.a = 0
	tween.tween_property($Title,"modulate:a",1,1)
	tween.parallel().tween_property($StartButton,"modulate:a",1,1)
	var StartButton_bitmap = BitMap.new()
	StartButton_bitmap.create_from_image_alpha($StartButton.texture_hover.get_image(),0.9)
	$StartButton.texture_click_mask = StartButton_bitmap
	
func _process(delta):
	pass


func _on_start_button_pressed():
	$StartButton.texture_normal = $StartButton.texture_pressed
	$StartButton.disabled = true
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property($StartButton,"position:y",256,0.7).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property($StartButton,"modulate:a",0,0.7)
	tween.tween_property($Title,"modulate:a",0,0.5)
	tween.tween_callback(emit).set_delay(0.5)

func emit():
	game_started.emit()
	
