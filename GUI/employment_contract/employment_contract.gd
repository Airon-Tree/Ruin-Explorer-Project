class_name EmploymentContract
extends CanvasLayer

@export_file("*.tscn")
var level_select_scene: String = "res://Scenes/level_select.tscn"

signal contract_confirmed

@onready var _panel: Panel = $Panel
@onready var _confirm_button: Button = $Panel/MarginContainer/VBox/ConfirmButton
@onready var _signature_area: SignatureArea = $Panel/MarginContainer/VBox/SignatureArea

@onready var _error_sfx: AudioStreamPlayer2D = $ErrorSFX

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_confirm_button.pressed.connect(_on_confirm_pressed)


func open() -> void:
	visible = true


func _on_confirm_pressed() -> void:
	# Require at least some drawn signature
	if not _signature_area.has_signature:
		if _error_sfx:
			_error_sfx.play()
		return

	if SaveManager:
		SaveManager.contract_signed = true

	visible = false

	# if still on the TitleScreen, jump to Level Select
	if level_select_scene != "":
		var current_scene := get_tree().current_scene
		if current_scene and current_scene.name == "TitleScreen":
			get_tree().change_scene_to_file(level_select_scene)
