class_name ExpressTrain
extends Node2D

@export var speed: float = 900.0
@export var life_time: float = 4.0

@export var shake_duration: float = 0.7
@export var shake_magnitude: float = 10.0

@onready var _hurt_box: HurtBox = $HurtBox
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _sfx: AudioStreamPlayer2D = $SFX

var _direction: Vector2 = Vector2.RIGHT

# Testing
# func _ready() -> void:
	# setup(Vector2.RIGHT)

# Called by the booth when the train spawns.
# `direction` is usually Vector2.RIGHT or Vector2.LEFT
func setup(direction: Vector2) -> void:
	_direction = direction.normalized()
	
	# Flip
	if _direction.x < 0.0:
		scale.x = -abs(scale.x)
	else:
		scale.x = abs(scale.x)
	
	if _sfx:
		_sfx.play()
	
	_start_life_timer()
	_start_screen_shake()


func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta


func _start_life_timer() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()


func _start_screen_shake() -> void:
	# Uses global PlayerManager and the player's camera.
	if not PlayerManager or not PlayerManager.player:
		# print("no player")
		return
	
	var camera: Camera2D = PlayerManager.player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		# print("camera null")
		return
	
	var original_offset: Vector2 = camera.offset
	var elapsed: float = 0.0
	
	while elapsed < shake_duration:
		var t: float = elapsed / shake_duration
		var strength: float = shake_magnitude * (1.0 - t)
		
		camera.offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	camera.offset = original_offset
	
	# print("not working")
