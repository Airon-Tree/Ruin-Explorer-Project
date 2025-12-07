class_name InventoryUI
extends Control

const INVENTORY_SLOT := preload("res://GUI/pause_menu/inventory/inventory_slot.tscn")

@export var data: InventoryData

var focus_index: int = 0
var _is_open: bool = false


func _ready() -> void:
	PauseMenu.shown.connect(_on_pause_shown)
	PauseMenu.hidden.connect(_on_pause_hidden)
	
	if data:
		data.changed.connect(_on_inventory_changed)
	
	clear_inventory()


func _on_pause_shown() -> void:
	_is_open = true
	update_inventory(focus_index)


func _on_pause_hidden() -> void:
	_is_open = false
	clear_inventory()


func clear_inventory() -> void:
	for child in get_children():
		child.queue_free()


func update_inventory(start_focus: int = 0) -> void:
	if data == null:
		return
	
	clear_inventory()
	
	var index := 0
	for slot_data in data.slots:
		var slot_ui: InventorySlotUI = INVENTORY_SLOT.instantiate()
		add_child(slot_ui)
		slot_ui.slot_data = slot_data
		
		slot_ui.focus_entered.connect(_on_slot_focus.bind(index))
		
		index += 1
	
	await get_tree().process_frame
	if get_child_count() > 0:
		var clamped: int = clampi(start_focus, 0, get_child_count() - 1)
		get_child(clamped).grab_focus()


func _on_slot_focus(index: int) -> void:
	focus_index = index



func _on_inventory_changed() -> void:
	if not _is_open:
		return
	
	update_inventory(focus_index)
