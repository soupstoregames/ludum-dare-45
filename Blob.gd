extends StaticBody2D

var BLOB = load("res://Blob.tscn")
var CREEP = load("res://EnemyCreep.tscn")

var max_health = 100
var current_health = 100
var heal_per_tick = 20

var required_growth = 15
var current_growth = 0
var growth_level = 0

onready var ground_tilemap = get_tree().get_root().get_node("World/Ground")
onready var buildings_tilemap = get_tree().get_root().get_node("World/Buildings")

func apply_damage(amount):
	current_health -= amount
	if current_health <= 0:
		die()
		return
	if current_health < max_health:
		update_health_bar()

func die():
	queue_free()

func update_health_bar():
	$Healthbar.show()
	var frame = floor((float(current_health) / max_health) * 10)
	$Healthbar.frame = frame

func spawn():
	var possible_spawn_locations = []
	
	if check_spawn_location(Vector2(0, -16)):
		possible_spawn_locations.append(Vector2(0, -16))
	if check_spawn_location(Vector2(0, 16)):
		possible_spawn_locations.append(Vector2(0, 16))
	if check_spawn_location(Vector2(-16, 0)):
		possible_spawn_locations.append(Vector2(-16, 0))
	if check_spawn_location(Vector2(16, 0)):
		possible_spawn_locations.append(Vector2(16, 0))
		
	if possible_spawn_locations.size() == 0:
		return
		
	var spawn_point = possible_spawn_locations[randi() % possible_spawn_locations.size()]
	var blob_instance = BLOB.instance()
	get_parent().add_child(blob_instance)
	blob_instance.position = global_position + spawn_point

func check_spawn_location(loc):
	var tile = ground_tilemap.world_to_map(global_position + loc)
	var cell = ground_tilemap.get_cellv(tile)
	if cell == 2:
		return false
	
	$Raycast.cast_to = loc
	$Raycast.force_raycast_update()
	return $Raycast.get_collider() == null

func spawn_creep(number):
	for i in range(number):
		var creep_instance = CREEP.instance()
		get_parent().get_parent().get_node("Creeps").add_child(creep_instance)
		creep_instance.position = global_position + Vector2(rand_range(-7, 7), rand_range(-7, 7))

func _on_Growth_timeout():
	# heal up before growing any furthert
	if current_health < max_health:
		current_health += heal_per_tick
		update_health_bar()
		if current_health >= max_health:
			current_health = max_health
			$Healthbar.hide()
		return
		
	current_growth += 1
	# see if we've reached the next stage
	if current_growth >= required_growth:
		current_growth = 0
		if growth_level < 2:
			$AnimatedSprite.frame += 1
			growth_level += 1
			required_growth *= 2
			max_health *= 2
			current_health = max_health
			
			# when grown to full size, harvest the tile
			if growth_level == 2:
				var tile = ground_tilemap.world_to_map(global_position)
				# grass
				if ground_tilemap.get_cellv(tile) == 0:
					spawn_creep(3)
				ground_tilemap.set_cellv(tile, 3)
				
				# trees
				if buildings_tilemap.get_cellv(tile) == 16:
					spawn_creep(6)
				buildings_tilemap.set_cellv(tile, -1)
		
		else:
			spawn()