class_name HurtBox
extends Area2D

@export var damage : int = 1


func _ready():
	area_entered.connect( _area_entered )
	pass

func _process(delta):
	pass
	
func _area_entered( a : Area2D) -> void:
	if a is HitBox:
		a.take_damage( self )
	pass
