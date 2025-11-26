class_name InteractDoor
extends Area2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var hint_offset: Vector2 = Vector2(0, -40)

@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var interact_hint = $InteractHint

var is_open: bool = false
var player_in_range: bool = false
var current_player: Node2D = null

func _ready() -> void:
	sprite.texture = closed_texture
	solid_shape.disabled = false

func _process(_delta) -> void:
	# 提示跟随玩家头顶
	if current_player and interact_hint.visible:
		interact_hint.global_position = current_player.global_position + hint_offset

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		toggle()

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func open() -> void:
	is_open = true
	sprite.texture = open_texture
	solid_shape.set_deferred("disabled", true)

func close() -> void:
	is_open = false
	sprite.texture = closed_texture
	solid_shape.set_deferred("disabled", false)

func _on_body_entered(body: Node2D) -> void:
	interact_hint.show()
	if body is Player:
		current_player = body
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	interact_hint.hide()
	if body is Player:
		player_in_range = false
