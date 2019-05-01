extends Node

onready var stageScene = preload("res://scenes/stage.tscn")

func _ready():
	pass

func _on_start_game_pressed():
	#get_tree().change_scene("res://scenes/stage.tscn")
	get_tree().change_scene_to(stageScene)


func _on_exit_pressed():
	get_tree().quit()
