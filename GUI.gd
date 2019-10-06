extends MarginContainer

onready var player = get_tree().get_root().get_node("World/Navigation2D/Human")
onready var scorekeeper = get_tree().get_root().get_node("World/ScoreKeeper")

func _input(event):
	if event.is_action_pressed("menu"):
		if get_tree().paused:
			$CanvasLayer/PauseMenu.visible = false
			get_tree().paused = false
		else:
			$CanvasLayer/PauseMenu.visible = true
			get_tree().paused = true

func _ready():
	get_node("CanvasLayer/LifeBar").max_value = player.HEALTH
	get_node("CanvasLayer/LifeBar").value = player.current_health
	
	get_node("CanvasLayer/VBoxContainer2/HBoxContainer/WoodAmount").text = str(player.wood)

func _on_Human_health_changed():
	get_node("CanvasLayer/LifeBar").value = player.current_health


func _on_Human_wood_changed():
	get_node("CanvasLayer/VBoxContainer2/HBoxContainer/WoodAmount").text = str(player.wood)

func _on_Restart_pressed():
	$CanvasLayer/PauseMenu.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_ExitToDesktop_pressed():
	get_tree().quit()

func _on_ScoreKeeper_score_changed():
	get_node("CanvasLayer/VBoxContainer3/ScoreAmount").text = str(scorekeeper.score)

func _on_ScoreKeeper_game_lost():
	get_tree().paused = true
	get_node("CanvasLayer/VBoxContainer3/ScoreAmount").text = "0"
	$CanvasLayer/PauseMenu.visible = true
	$CanvasLayer/PauseMenu/Paused.visible = false
	$CanvasLayer/PauseMenu/GameOver.visible = true

func _on_ScoreKeeper_game_won():
	get_tree().paused = true
	$CanvasLayer/PauseMenu.visible = true
	$CanvasLayer/PauseMenu/Paused.visible = false
	$CanvasLayer/PauseMenu/GameWon.visible = true


func _on_ExitToMainMenu_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
