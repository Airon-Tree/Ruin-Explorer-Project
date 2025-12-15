# BGMManager.gd
extends Node

@onready var player = $AudioStreamPlayer

func _ready() -> void:
	if player.stream:
		player.stream.loop = true
	player.finished.connect(_on_player_finished)


func play_bgm(music: AudioStream) -> void:
	if player.stream != music:
		player.stream = music
		player.stream.loop = true
	
	if not player.playing:
		player.play()


func _on_player_finished() -> void:
	if player.stream:
		player.play()


func stop_bgm() -> void:
	player.stop()
	
