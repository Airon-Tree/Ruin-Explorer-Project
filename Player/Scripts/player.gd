class_name Player
extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO



@onready var animation_player : AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine = $StateMachine

signal DirectionChanged( new_direction : Vector2)


func _ready():
	state_machine.Initialize(self)
	var hurtbox = $Interactions/HurtBox  # 根据你的实际路径调整
	hurtbox.Damaged.connect(_on_damaged)
	pass
	
func _process(delta):
	#direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	#direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()

func SetDirection() -> bool:
	var new_dir : Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false
		
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
		
	if new_dir == cardinal_direction:
		return false
	
	
	
	cardinal_direction = new_dir
	DirectionChanged.emit( new_dir )
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true
	
	
func UpdateAnimation( state : String) -> void:
	animation_player.play( state + "_" + AnimDirection())
	pass
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
		
###############################

@export var max_health: int = 100
var current_health: int = 100



func _on_damaged(damage: int) -> void:
	current_health -= damage
	print("Take damage！Current health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	print("player died！")
