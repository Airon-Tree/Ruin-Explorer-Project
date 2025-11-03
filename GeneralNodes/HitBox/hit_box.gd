class_name HitBox
extends Area2D

@export var damage : int = 1
@export var damage_interval : float = 0.5

var overlapping_hurtboxes: Dictionary = {}

func _ready():
	area_entered.connect(AreaEntered)
	area_exited.connect(AreaExited)
	body_entered.connect(BodyEntered)  # 额外监听body
	
	print("======= HitBox 初始化 =======")
	print("父节点: ", get_parent().name)
	print("Collision Layer: ", collision_layer)
	print("Collision Mask: ", collision_mask)
	print("Monitoring: ", monitoring)
	print("Monitorable: ", monitorable)

func _process(delta):
	# 每秒打印一次状态
	#if Engine.get_frames_drawn() % 60 == 0:
		#print("HitBox活着，重叠数量: ", overlapping_hurtboxes.size())
	
	for hurtbox in overlapping_hurtboxes.keys():
		overlapping_hurtboxes[hurtbox] += delta
		
		if overlapping_hurtboxes[hurtbox] >= damage_interval:
			if is_instance_valid(hurtbox):
				print(">>> 造成持续伤害")
				hurtbox.TakeDamage(damage)
			overlapping_hurtboxes[hurtbox] = 0.0

func BodyEntered(body: Node2D) -> void:
	print("")
	#print("!!! HitBox检测到Body进入: ", body.name)

func AreaEntered(a: Area2D) -> void:
	#print("!!! HitBox检测到Area进入: ", a.name)
	#print("    - Area的脚本: ", a.get_script())
	#print("    - 是HurtBox?: ", a is HurtBox)
	
	if a is HurtBox:
		#print(">>> 确认是HurtBox，立即造成伤害！")
		a.TakeDamage(damage)
		overlapping_hurtboxes[a] = 0.0
	#else:
		#print(">>> 不是HurtBox类型")

func AreaExited(a: Area2D) -> void:
	#print("!!! HitBox检测到Area离开: ", a.name)
	if a is HurtBox:
		if overlapping_hurtboxes.has(a):
			overlapping_hurtboxes.erase(a)
