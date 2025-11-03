class_name Door
extends Area2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var is_open: bool = false

func _ready() -> void:
	# Start closed
	if closed_texture:
		sprite.texture = closed_texture

func open() -> void:
	is_open = true
	if open_texture:
		sprite.texture = open_texture

func _on_body_entered(body: Node2D) -> void:
	if not is_open:
		return
	
	if body is Player:
		print("YOU WIN!")
		get_tree().quit()


func _on_key_card_picked_up() -> void:
	open()
