class_name KeyCard
extends Area2D

signal picked_up

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("picked_up")
		queue_free()


func _on_KeyCard_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("picked_up")
		queue_free()
