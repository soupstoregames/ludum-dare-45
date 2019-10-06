extends Node

func _ready():
	get_tree().paused = false

func _on_StartGame_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_ExitToDesktop_pressed():
	get_tree().quit()


func _on_Tutorial_pressed():
	get_tree().change_scene("res://Tutorial.tscn")
