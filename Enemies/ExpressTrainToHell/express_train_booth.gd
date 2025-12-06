class_name ExpressTrainBooth
extends Node2D

# --- CONFIG ---------------------------------------------------------

@export var seconds_per_light: float = 30.0
@export var max_lights: int = 4

# how long the booth stays disabled after taking damage
@export var disabled_duration: float = 8.0
@export var disabled_tint: Color = Color(0.6, 0.2, 0.2, 1.0)

# Full booth sprites: index 0 = 0 lights, 1 = 1 light, ..., 4 = 4 lights
@export var light_textures: Array[Texture2D]

# --- NODES ----------------------------------------------------------

@onready var _booth_sprite: Sprite2D = $BoothSprite
@onready var _light_timer: Timer = $LightTimer
@onready var _disabled_timer: Timer = $DisabledTimer
@onready var _hit_box: HitBox = $HitBox
@onready var _light_beep: AudioStreamPlayer2D = $LightBeepPlayer
@onready var _train_warning: AudioStreamPlayer2D = $TrainWarningPlayer
# --- STATE ----------------------------------------------------------

var _lights_on: int = 0
var _disabled: bool = false


func _ready() -> void:
	# set up the light timer
	_light_timer.wait_time = seconds_per_light
	_light_timer.autostart = true
	_light_timer.one_shot = false
	_light_timer.timeout.connect(_on_light_timer_timeout)
	
	# disabled timer
	_disabled_timer.timeout.connect(_on_disabled_timer_timeout)
	
	# connect damage signal from HitBox
	if _hit_box:
		_hit_box.damaged.connect(_on_hit_box_damaged)
	
	_update_lights()
	_update_visual_state()


# -------------------------------------------------------------------
#  LIGHT / TIMER LOGIC
# -------------------------------------------------------------------

func _on_light_timer_timeout() -> void:
	if _disabled:
		return
	
	# increase light count up to max
	if _lights_on < max_lights:
		_lights_on += 1
		_update_lights()
		
		if _light_beep:
			_light_beep.play()
	else:
		# later we will trigger the train here
		_reset_lights()


func _reset_lights() -> void:
	_lights_on = 0
	_update_lights()


func _update_lights() -> void:
	# clamp the light count safely
	_lights_on = clampi(_lights_on, 0, max_lights)
	
	if not _booth_sprite:
		return
	
	if light_textures.size() == 0:
		return
	
	# index matches number of lights directly: 0..max_lights
	var idx: int = clampi(_lights_on, 0, light_textures.size() - 1)
	_booth_sprite.texture = light_textures[idx]

# -------------------------------------------------------------------
#  DAMAGE / DISABLE LOGIC
# -------------------------------------------------------------------

func _on_hit_box_damaged(hurt_box: HurtBox) -> void:
	if _disabled:
		return
	# here we can later add HP if you want multiple hits
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
