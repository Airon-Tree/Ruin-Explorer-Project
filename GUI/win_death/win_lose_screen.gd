class_name WinLoseScreen
extends CanvasLayer

enum Mode { NONE, WIN, DEATH }

@export_file("*.tscn")
var level_select_scene: String = "res://Scenes/level_select.tscn"

@onready var _title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var _buttons_container: VBoxContainer = $Panel/VBoxContainer/Buttons
@onready var _try_again_button: Button = $Panel/VBoxContainer/Buttons/TryAgainButton
@onready var _level_select_button: Button = $Panel/VBoxContainer/Buttons/LevelSelectButton

var _mode: Mode = Mode.NONE


func _ready() -> void:
	
	hide()
	
	_try_again_button.pressed.connect(_on_try_again_pressed)
	_level_select_button.pressed.connect(_on_level_select_pressed)


# -------------------------------------------------------------------
# Public API
# -------------------------------------------------------------------

func show_win() -> void:
	_mode = Mode.WIN
	_title_label.text = "You Escaped!"
	
	# If want to allow replay from win, keep this true.
	# If want only "Select Another Level" on win, set to false.
	_try_again_button.visible = true
	
	_level_select_button.text = "Select Another Level"
	
	_open()


func show_death() -> void:
	_mode = Mode.DEATH
	_title_label.text = "You Died!"
	
	_try_again_button.visible = true
	_level_select_button.text = "Select Another Level"
	
	_open()




func _open() -> void:
	get_tree().paused = true
	show()
	
	if _try_again_button.visible:
		_try_again_button.grab_focus()
	else:
		_level_select_button.grab_focus()


func _close() -> void:
	hide()
	get_tree().paused = false

func _reset_player_for_restart() -> void:
	if PlayerManager and PlayerManager.player:
		var p: Player = PlayerManager.player
		p.reset_after_death()

func _reset_player_hp_to_full() -> void:
	# Use global PlayerManager autoload
	if PlayerManager and PlayerManager.player:
		var player := PlayerManager.player
		var needed: int = player.max_hp - player.hp
		if needed != 0:
			player.update_hp(needed)



func _on_try_again_pressed() -> void:
	_reset_player_for_restart()
	# Reset player state before reloading

	_close()
	get_tree().reload_current_scene()


func _on_level_select_pressed() -> void:
	_reset_player_for_restart()

	_close()
	if level_select_scene != "":
		get_tree().change_scene_to_file(level_select_scene)
