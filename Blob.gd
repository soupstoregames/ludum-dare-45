extends StaticBody2D

var BLOB = load("res://Blob.tscn")
var CREEP = load("res://EnemyCreep.tscn")

var max_health = 25
var current_health = max_health
var heal_per_tick = 10

var required_growth = 12
var current_growth = 0
var growth_level = 0

onready var ground_tilemap = get_tree().get_root().get_node("World/Navigation2D/Ground")
onready var buildings_tilemap = get_tree().get_root().get_node("World/Navigation2D/Buildings")

signal blob_died
signal building_devoured
signal trees_devoured

func _ready():
	connect("building_devoured", get_tree().get_root().get_node("World/ScoreKeeper"), "_on_Blob_building_devoured")
	connect("trees_devoured", get_tree().get_root().get_node("World/ScoreKeeper"), "_on_Blob_trees_devoured")

func apply_damage(amount):
	if self.visible == false:
		return
	current_health -= amount
	if current_health <= 0:
		die()
		return
	if current_health < max_health:
		update_health_bar()

func die():
	self.visible = false
	emit_signal("blob_died")
	$death_sound.play()

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
		$Growth.wait_time = 15
		$AnimatedSprite.frame += 1
		return
	
	$Growth.wait_time = 1
		
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
	if get_parent().get_parent().get_node("Creeps").get_child_count() > 50:
		return
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
		
	current_growth += rand_range(1, 4)
	# see if we've reached the next stage
	if current_growth >= required_growth:
		current_growth = 0
		if growth_level < 2:
			$AnimatedSprite.frame += 1
			growth_level += 1
			required_growth *= 1.5
			max_health *= 2
			current_health = max_health
			
			# when grown to full size, harvest the tile
			if growth_level == 2:
				var tilePos = ground_tilemap.world_to_map(global_position)
				# grass
				if ground_tilemap.get_cellv(tilePos) == 0:
					spawn_creep(1)
				ground_tilemap.set_cellv(tilePos, 3)
				var tile = buildings_tilemap.get_cellv(tilePos)
				# trees
				if tile == 0 or tile == 1 or tile == 2 or tile == 3 or tile == 4:
					spawn_creep(2)
					emit_signal("building_devoured")
				if tile == 16:
					spawn_creep(1)
					emit_signal("trees_devoured")
				buildings_tilemap.set_cellv(tilePos, -1)
				buildings_tilemap.update_dirty_quadrants()
		
		else:
			spawn()

func _on_death_sound_finished():
	queue_free()
