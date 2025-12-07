class_name ExpressTrainBooth
extends Node2D


@export var seconds_per_light: float = 30.0
@export var max_lights: int = 4

# how long the booth stays disabled after taking damage
@export var disabled_duration: float = 8.0
@export var disabled_tint: Color = Color(0.6, 0.2, 0.2, 1.0)

@export var light_textures: Array[Texture2D]

@export var gem_item_data: ItemData
@export var ticket_items_by_light: Array[ItemData] = []

@export var train_scene: PackedScene


@onready var _booth_sprite: Sprite2D = $BoothSprite
@onready var _light_timer: Timer = $LightTimer
@onready var _disabled_timer: Timer = $DisabledTimer
@onready var _hit_box: HitBox = $HitBox
@onready var _light_beep: AudioStreamPlayer2D = $LightBeepPlayer
@onready var _train_warning: AudioStreamPlayer2D = $TrainWarningPlayer

@export var hint_offset: Vector2 = Vector2(0, -32)

@onready var _interact_area: Area2D = $InteractArea
@onready var _interact_hint: Sprite2D = $InteractHint


var _player_nearby: bool = false
var _current_player: Player = null

var _lights_on: int = 0
var _disabled: bool = false


func _ready() -> void:
	# set up the light timer
	_light_timer.wait_time = seconds_per_light
	# _light_timer.autostart = true
	_light_timer.one_shot = false
	_light_timer.timeout.connect(_on_light_timer_timeout)
	_light_timer.start()
	
	# disabled timer
	_disabled_timer.timeout.connect(_on_disabled_timer_timeout)
	
	# connect damage signal from HitBox
	if _hit_box:
		_hit_box.damaged.connect(_on_hit_box_damaged)
		
		# interaction area
	if _interact_area:
		_interact_area.body_entered.connect(_on_interact_body_entered)
		_interact_area.body_exited.connect(_on_interact_body_exited)
	
	if _interact_hint:
		_interact_hint.visible = false
	
	_update_lights()
	_update_visual_state()



func _on_light_timer_timeout() -> void:
	if _disabled:
		#print("disabled")
		return
	
	# increase light count up to max
	if _lights_on < max_lights:
		_lights_on += 1
		#print("light increased")
		_update_lights()
		
		if _light_beep:
			_light_beep.play()
	else:
		#print("light reseted")
		_trigger_train()
		_reset_lights()


func _reset_lights() -> void:
	_lights_on = 0
	_update_lights()


func _update_lights() -> void:
	# clamp the light count
	
	_lights_on = clampi(_lights_on, 0, max_lights)
	
	if not _booth_sprite:
		return
	
	if light_textures.size() == 0:
		return
	
	var idx: int = clampi(_lights_on, 0, light_textures.size() - 1)
	_booth_sprite.texture = light_textures[idx]

func _trigger_train() -> void:
	if train_scene == null:
		return
	
	# warning sound
	if _train_warning:
		_train_warning.play()
	
	var level_root: Node = get_tree().current_scene
	if level_root == null:
		return
	
	# Instance the train and add it to the level
	var train_instance: Node = train_scene.instantiate()
	level_root.add_child(train_instance)
	
	# decide Y position: 
	# trainTarget node if it exists, 
	# otherwise player Y, otherwise booth Y
	var target_y: float = global_position.y
	
	var target_node: Node = level_root.get_node_or_null("TrainTarget")
	if target_node is Node2D:
		target_y = (target_node as Node2D).global_position.y
	elif PlayerManager and PlayerManager.player:
		target_y = PlayerManager.player.global_position.y
	
	# decide starting X: 
	# 
	# defualt speed 900/s
	var start_x: float = global_position.x - 1200.0
	if PlayerManager and PlayerManager.player:
		start_x = PlayerManager.player.global_position.x - 1200.0
	
	# train uses the ExpressTrain class, call setup(direction)
	if train_instance is ExpressTrain:
		var t: ExpressTrain = train_instance as ExpressTrain
		t.global_position = Vector2(start_x, target_y)
		t.setup(Vector2.RIGHT)
	else:
		if "global_position" in train_instance:
			train_instance.global_position = Vector2(start_x, target_y)


# -------------------------------------------------------------------
#  damage/disable logic
# -------------------------------------------------------------------

func _on_hit_box_damaged(hurt_box: HurtBox) -> void:
	if _disabled:
		return
	# can add HP if want multiple hits
	_set_disabled(true)


func _set_disabled(disabled: bool) -> void:
	if _disabled == disabled:
		return
	
	_disabled = disabled
	_update_visual_state()
	
	if _disabled:
		_light_timer.stop()
		_disabled_timer.start(disabled_duration)
	else:
		_light_timer.start()


func _on_disabled_timer_timeout() -> void:
	_set_disabled(false)


func _update_visual_state() -> void:
	if not _booth_sprite:
		return
	
	if _disabled:
		_booth_sprite.modulate = disabled_tint
	else:
		_booth_sprite.modulate = Color(1, 1, 1, 1)
		
		
		




func interact(player: Player) -> void:
	if _disabled:
		return
	
	var inv_data := PlayerManager.INVENTORY_DATA
	if inv_data == null:
		return
	
	# Check the player has at least one Gem
	if not _inventory_has_gem(inv_data):
		return
	
	# Decide which ticket item to give, based on current lights
	var light_index: int = clampi(_lights_on, 0, max_lights)
	if light_index < 0 or light_index >= ticket_items_by_light.size():
		return
	
	var ticket_item_res := ticket_items_by_light[light_index]
	if ticket_item_res == null:
		return
	
	_consume_gem(inv_data)
	_give_ticket(inv_data, ticket_item_res)
	
	_reset_lights()
	if _light_beep:
		_light_beep.play()
		
		
func _inventory_has_gem(inv_data: InventoryData) -> bool:
	if gem_item_data == null:
		return false
	
	for slot in inv_data.slots:
		if slot and slot.item_data == gem_item_data and slot.quantity > 0:
			return true
	
	return false


func _consume_gem(inv_data: InventoryData) -> void:
	if gem_item_data == null:
		return
	
	for i in inv_data.slots.size():
		var slot := inv_data.slots[i]
		if slot and slot.item_data == gem_item_data and slot.quantity > 0:
			slot.quantity -= 1
			
			if slot.quantity <= 0:
				inv_data.slots[i] = null
				
			return


func _give_ticket(inv_data: InventoryData, ticket_item: ItemData) -> void:
	if ticket_item == null:
		return
	
	var added: bool = inv_data.add_item(ticket_item, 1)
	
	if not added:
		# play a "no space" sound or show a message
		return
	
	
	
	
	
	
func _on_interact_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_nearby = true
		_current_player = body
		if _interact_hint:
			_interact_hint.visible = true
			_update_hint_position()


func _on_interact_body_exited(body: Node2D) -> void:
	if body == _current_player:
		_player_nearby = false
		_current_player = null
		if _interact_hint:
			_interact_hint.visible = false


func _process(_delta: float) -> void:
	if _player_nearby:
		_update_hint_position()
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
			if _current_player:
				interact(_current_player)


func _update_hint_position() -> void:
	if _interact_hint and _current_player:
		_interact_hint.global_position = _current_player.global_position + hint_offset
