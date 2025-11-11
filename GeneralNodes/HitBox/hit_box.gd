class_name HitBox
extends Area2D

signal damaged( hurt_box : HurtBox )

func _ready():
	pass

	
func take_damage( hurt_box : HurtBox ) -> void:
	# print( "TakeDamage: ", damage)
	damaged.emit( hurt_box )
