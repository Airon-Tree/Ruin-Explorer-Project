class_name Desk
extends Node2D

func _ready():
	$HitBox.damaged.connect( _take_damage )
	pass
	
func _take_damage( _damage : int ) -> void:
	queue_free()
