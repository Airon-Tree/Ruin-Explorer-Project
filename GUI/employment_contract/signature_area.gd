class_name SignatureArea
extends Control

var _paths: Array = []
var _current_path: PackedVector2Array = PackedVector2Array()
var _drawing: bool = false

var has_signature: bool = false


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_load_signature()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drawing = true
			_current_path = PackedVector2Array()
			_current_path.append(event.position)
			has_signature = true
		else:
			if _drawing:
				_drawing = false
				if _current_path.size() > 1:
					_paths.append(_current_path)
					_save_signature()
	elif event is InputEventMouseMotion and _drawing:
		_current_path.append(event.position)
		queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)

	# background "paper"
	draw_rect(rect, Color(0.97, 0.97, 0.93, 1.0), true)

	# outline
	draw_rect(rect, Color(1, 1, 1, 1), false, 2.0)

	var color := Color(1, 0, 0, 1)
	var width := 2.0

	for path in _paths:
		for i in range(path.size() - 1):
			draw_line(path[i], path[i + 1], color, width)

	if _current_path.size() > 1:
		for i in range(_current_path.size() - 1):
			draw_line(_current_path[i], _current_path[i + 1], color, width)


func _save_signature() -> void:
	if not SaveManager:
		return
	
	# Store a copy of all paths on the SaveManager singleton
	SaveManager.contract_signature_paths = _paths.duplicate(true)


func _load_signature() -> void:
	if not SaveManager:
		return
	
	if not SaveManager.contract_signature_paths is Array:
		return
	
	var saved_paths: Array = SaveManager.contract_signature_paths
	if saved_paths.size() == 0:
		return
	
	_paths = saved_paths.duplicate(true)
	has_signature = true
	queue_redraw()
