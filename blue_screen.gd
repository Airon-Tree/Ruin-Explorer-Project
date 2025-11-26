extends Node2D

@onready var area = $Area2D
@onready var blue_screen_panel = $CanvasLayer/BlueScreenPanel
@onready var label = $CanvasLayer/BlueScreenPanel/Label
@onready var interact_hint = $InteractHint

@export_multiline var screen_text: String = "TEMPLATE, press E to exit"
#@export var interaction_hint: String = "[E] 查看"
@export var hint_offset: Vector2 = Vector2(0, -32)


var player_nearby = false
var screen_open = false
var e_was_pressed = false
var current_player: Node2D = null

func _ready():
	# 初始隐藏蓝屏
	blue_screen_panel.hide()
	
	# 连接信号
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# 设置文字
	label.text = screen_text

func _process(_delta):
	# 检测E键
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
		if player_nearby:
			toggle_screen()
	if current_player and interact_hint.visible:
		interact_hint.global_position = current_player.global_position + hint_offset

func _on_body_entered(body):
	# 检查节点名字
	if body.name == "Player":  # 改成你们玩家的实际名字
		player_nearby = true
		print("玩家靠近 BlueScreen")
		current_player = body
		interact_hint.show()

func _on_body_exited(body):
	if body.name == "Player":
		player_nearby = false
		print("玩家离开 BlueScreen")
		interact_hint.hide()
		if screen_open:
			close_screen()

func toggle_screen():
	if screen_open:
		close_screen()
	else:
		open_screen()

func open_screen():
	screen_open = true
	blue_screen_panel.show()

func close_screen():
	screen_open = false
	blue_screen_panel.hide()
