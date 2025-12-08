extends CanvasLayer

var hearts : Array[ HeartGUI ] = []


func _ready():
	for child in $Control/HFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append( child )
			child.visible = false
	pass
	
	
func update_hp( _hp: int, _max_hp: int ) -> void:
	update_max_hp( _max_hp )
	for i in _max_hp:
		update_heart( i, _hp)
		pass
	pass
	
	
func update_heart( _index : int, _hp : int ) -> void:
	var _value : int = clampi( _hp - _index * 10, 0, 10 )
	print("heart value: ", _value)
	hearts[ _index ].value = _value
	pass
	
func update_max_hp( _max_hp : int ) -> void:
	var _heart_count : int = roundi( _max_hp * 0.1 )
	print("heart count: ", _heart_count)
	for i in hearts.size():
		# print("heart size: ", hearts.size())
		if i < _heart_count:
			hearts[i].visible = true
			print("The number of heart shows: ", i)
		else:
			hearts[i].visible = false
			print("The number of heart hid: ", i)
	pass
