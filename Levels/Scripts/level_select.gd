extends Control

@export var level01_path : String = "res://Levels/Level01/01.tscn"


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file( level01_path )
