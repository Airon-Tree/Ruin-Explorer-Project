class_name Desk
extends Node2D

func _ready():
	$HitBox.damaged.connect( _take_damage )
	pass
	
func _take_damage( _damage : HurtBox ) -> void:
	queue_free()
