extends KinematicBody2D

onready var buildings_tilemap = get_tree().get_root().get_node("World/Buildings")
const BULLET = preload("res://Bullet.tscn")

const SPEED = 15
const BULLET_FORCE = 200

var movement = Vector2()

func _physics_process(delta):
	move()
	shoot()
	
func move():
	movement = Vector2()
	
	if Input.is_action_pressed("move_up"):
		movement.y += -1
	if Input.is_action_pressed("move_down"):
		movement.y += 1
	if Input.is_action_pressed("move_left"):
		movement.x += -1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
		
	movement = movement * SPEED
	movement = move_and_slide(movement)
	
func shoot():
	var point_vector = get_global_mouse_position() - position
	point_vector = point_vector.normalized()
		
	if Input.is_action_pressed("harvest"):
		$HarvestRaycast.cast_to = point_vector*16
		$HarvestRaycast.force_raycast_update()
		var collider = $HarvestRaycast.get_collider()
		if collider == null:
			if $HarvestSound.playing == true:
				$HarvestSound.stop()
			$HarvestLine.clear_points()
			return
		var pos = $HarvestRaycast.get_collision_point()
		var tile_coord = buildings_tilemap.world_to_map(pos)
		var tile = buildings_tilemap.get_cellv(tile_coord)
		$HarvestLine.clear_points()
		$HarvestLine.add_point(Vector2.ZERO)
		$HarvestLine.add_point(pos - global_position)
		if $HarvestSound.playing == false:
			$HarvestSound.play()
		return
	else:
		if $HarvestSound.playing == true:
			$HarvestSound.stop()
		$HarvestLine.clear_points()
		
	if Input.is_action_just_pressed("shoot"):
		var bullet_instance = BULLET.instance()
		get_parent().add_child(bullet_instance)
		bullet_instance.position = global_position + point_vector
		bullet_instance.apply_impulse(Vector2.ZERO, point_vector * BULLET_FORCE)
		
		$BulletSound.play()
		return