extends Node

var score = 0
var buildings = 0

signal score_changed
signal game_lost
signal game_won

func _ready():
	get_tree().paused = false
	var buildings_tilemap = get_tree().get_root().get_node("World/Navigation2D/Buildings")
	for x in range(64):
		for y in range(32):
			var tile = buildings_tilemap.get_cell(x, y)
			if tile == 0 or tile == 1 or tile == 2 or tile == 3 or tile == 4:
				score += 50
				buildings += 1 
			if tile == 16:
				score += 15
				buildings += 1
	emit_signal("score_changed")

func _physics_process(delta):
	var blob_count = get_parent().get_node("BlobController/Blobs").get_child_count()
	if blob_count == 0:
		emit_signal("game_won")

func _on_Blob_building_devoured():
	score -= 50
	if score <= 0:
		score = 0
	buildings -= 1
	if buildings <= 0:
		score = 0
		emit_signal("game_lost")
		
	emit_signal("score_changed")

func _on_Blob_trees_devoured():
	score -= 15
	if score <= 0:
		score = 0
	buildings -= 1
	if buildings <= 0:
		score = 0
		emit_signal("game_lost")
		
	emit_signal("score_changed")

func _on_Creep_killed():
	score += 10
	emit_signal("score_changed")

func _on_Human_player_died():
	score = 0
	emit_signal("game_lost")
