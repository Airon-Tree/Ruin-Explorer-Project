extends Control


@export_file("*.tscn")
var level_select_scene: String = "res://Levels/level_select.tscn"

@export_file("*.tscn")
var contract_scene: String = "res://GUI/employment_contract/employment_contract.tscn"

func _ready():
	# 可选:添加淡入效果
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _on_start_button_pressed() -> void:
	#print("按钮被点击了!") 
	if SaveManager and SaveManager.contract_signed:
		if level_select_scene != "":
			get_tree().change_scene_to_file(level_select_scene)
		return
	
	# Otherwise, show the contract
	var scene: PackedScene = load(contract_scene)
	var contract := scene.instantiate() as EmploymentContract
	get_tree().root.add_child(contract)
	contract.open()



func _on_quit_button_pressed() -> void:
	get_tree().quit()
