extends Control

@export var level01_path : String = "res://Levels/Level01/level_01.tscn"
@export var level02_path : String = "Level-02 path"
@export var level03_path : String = "res://Levels/Level01/level_03.tscn"


func _on_level_1_button_pressed() -> void:
	var level_path := level01_path
	var spawn_name := "PlayerSpawn"
	var offset     := Vector2.ZERO


	LevelManager.load_new_level(level_path, spawn_name, offset)




func _on_level_2_button_pressed() -> void:
	var level_path := level02_path
	var spawn_name := "PlayerSpawn"
	var offset     := Vector2.ZERO


	LevelManager.load_new_level(level_path, spawn_name, offset)



func _on_level_3_button_pressed() -> void:
	var level_path := level03_path
	var spawn_name := "PlayerSpawn"
	var offset     := Vector2.ZERO


	LevelManager.load_new_level(level_path, spawn_name, offset)
