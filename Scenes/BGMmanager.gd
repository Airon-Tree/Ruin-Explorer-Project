# BGMManager.gd
extends Node

@onready var player = $AudioStreamPlayer

func play_bgm(music: AudioStream):
	if player.stream != music:
		player.stream = music
		player.play()

func stop_bgm():
	player.stop()
	
	
