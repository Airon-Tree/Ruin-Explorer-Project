class_name HurtBox
extends Area2D

signal Damaged(damage: int)

func _ready():
	# 强制设置，覆盖任何其他设置
	set_deferred("monitorable", true)
	set_deferred("monitoring", false)
	
	# 延迟一帧后再打印，确保设置生效
	await get_tree().process_frame
	
	print("======= HurtBox 初始化 =======")
	print("父节点: ", get_parent().name)
	print("Collision Layer: ", collision_layer)
	print("Collision Mask: ", collision_mask)
	print("Monitoring: ", monitoring)
	print("Monitorable: ", monitorable)

func _process(delta):
	if Engine.get_frames_drawn() % 60 == 0:
		#print("HurtBox活着，位置: ", global_position, " Monitorable: ", monitorable)
		print("")
	
func TakeDamage(damage: int) -> void:
	print("========== TakeDamage 被调用！！！==========")
	print("伤害值: ", damage)
	Damaged.emit(damage)
