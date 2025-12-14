extends CanvasLayer

var hearts: Array[HeartGUI] = []

@onready var stamina_gui: StaminaGUI = $Control/Stamina

func _ready():
	for child in $Control/HFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append(child)
			child.visible = false

func update_hp(_hp: int, _max_hp: int) -> void:
	update_max_hp(_max_hp)
	for i in _max_hp:
		update_heart(i, _hp)

func update_heart(_index: int, _hp: int) -> void:
	var _value: int = clampi(_hp - _index * 10, 0, 10)
	hearts[_index].value = _value

func update_max_hp(_max_hp: int) -> void:
	var _heart_count: int = roundi(_max_hp * 0.1)
	for i in hearts.size():
		hearts[i].visible = (i < _heart_count)

func update_stamina(sta: int, max_sta: int) -> void:
	if stamina_gui == null:
		return
	stamina_gui.max_value = max_sta
	stamina_gui.value = sta

func set_hp_bar_visible(is_visible: bool) -> void:
	visible = is_visible
