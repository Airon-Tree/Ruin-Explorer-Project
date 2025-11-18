extends Control

@export var level01_path : String = "res://Levels/Level01/01.tscn"


func _on_level_1_button_pressed() -> void:
	var level_path := level01_path
	var spawn_name := "PlayerSpawn"
	var offset     := Vector2.ZERO


	LevelManager.load_new_level(level_path, spawn_name, offset)
	
