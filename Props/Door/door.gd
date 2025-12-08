class_name Door
extends Area2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_open: bool = false

func _ready() -> void:
	sprite.texture = closed_texture
	solid_shape.disabled = false

func open() -> void:
	is_open = true

	sprite.texture = open_texture
	solid_shape.set_deferred("disabled", true)

func _on_body_entered(body: Node2D) -> void:
	if not is_open:
		return
	
	if body is Player:
		var ui_node := get_tree().current_scene.get_node_or_null("WinLoseScreen")
		if ui_node is WinLoseScreen:
			var screen := ui_node as WinLoseScreen
			screen.show_win()
		else:
			get_tree().change_scene_to_file("res://Scenes/level_select.tscn")


func _on_key_card_picked_up() -> void:
	open()
