class_name Desk
extends Node2D

func _ready():
	$HitBox.Damaged.connect( TakeDamage )
	pass
	
func TakeDamage( _damage : int ) -> void:
	queue_free()
