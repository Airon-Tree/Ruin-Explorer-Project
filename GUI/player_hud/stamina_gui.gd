class_name StaminaGUI
extends Control

@onready var sprite: Sprite2D = $Sprite2D

@export var max_value: int = 26
@export var frame_offset: int = 21 # If your bar frames start at some index, set it here.

var _value: int = 26

var value: int:
	set(v):
		_value = clampi(v, 0, max_value)
		update_sprite()
	get:
		return _value

func _ready() -> void:
	update_sprite()

func update_sprite() -> void:
	# Map value (0..26) -> frame index
	# If your sheet has exactly 27 frames for the bar, you probably want 0..26.
	# If you truly want max_stamina=26 with 27 frames, treat 26 as "full" and clamp frame to 26.
	var frame_idx := clampi(_value, 0, max_value)
	sprite.frame = frame_offset + frame_idx
