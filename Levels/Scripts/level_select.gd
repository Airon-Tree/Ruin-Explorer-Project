extends Control

@export var level01_path : String = "res://Levels/Level01/01.tscn"


func _on_level_1_button_pressed() -> void:
	var level_path := level01_path
	var spawn_name := "Spawn_From_Menu"
	var offset     := Vector2.ZERO

	LevelManager.target_transition = spawn_name
	LevelManager.position_offset = offset
	get_tree().change_scene_to_file(level_path)
