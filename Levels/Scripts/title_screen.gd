extends Control

func _ready():
	# 可选:添加淡入效果
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _on_start_button_pressed() -> void:
	print("按钮被点击了!") 
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")



func _on_quit_button_pressed() -> void:
	get_tree().quit()
