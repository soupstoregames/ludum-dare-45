extends KinematicBody2D

onready var buildings_tilemap = get_tree().get_root().get_node("World/Navigation2D/Buildings")
const BULLET = preload("res://Bullet.tscn")

const SPEED = 14
const BULLET_FORCE = 200
const HEALTH = 50
var current_health = HEALTH

var movement = Vector2()
var shoot = false
var harvest_tile = Vector2()

var wood = 0

signal health_changed
signal wood_changed

signal building_devoured
signal trees_devoured
signal player_died

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		shoot = true
	if event.is_action_released("shoot"):
		shoot = false

func _physics_process(delta):
	$AttackColor.visible = false
	move()
	shoot()
	
func apply_damage(amount):
	current_health -= amount
	$Camera2D.shake_amount = rand_range(0.75, 1.5)
	$AttackColor.visible = true
	emit_signal("health_changed")
	if current_health <= 0:
		die()
		return

func die():
	emit_signal("player_died")

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
			$HarvestTimer.stop()
			if $HarvestSound.playing == true:
				$HarvestSound.stop()
			$HarvestLine.clear_points()
			return
		var pos = $HarvestRaycast.get_collision_point()
		var tile_coord = buildings_tilemap.world_to_map(pos)
		harvest_tile = tile_coord
		var tile = buildings_tilemap.get_cellv(tile_coord)
		$HarvestLine.clear_points()
		$HarvestLine.add_point(Vector2.ZERO)
		$HarvestLine.add_point(pos - global_position)
		if $HarvestTimer.is_stopped():
			$HarvestTimer.start()
		if $HarvestSound.playing == false:
			$HarvestSound.play()
		return
	else:
		$HarvestTimer.stop()
		if $HarvestSound.playing == true:
			$HarvestSound.stop()
		$HarvestLine.clear_points()
		
	if shoot and Input.is_action_pressed("shoot"):
		if $AttackTimer.time_left <= 0:
			var bullet_instance = BULLET.instance()
			if wood > 0:
				bullet_instance.super_charge()
				wood -= 1
				$BulletChargedSound.play()
				emit_signal("wood_changed")
			else:
				$BulletSound.play()
			get_parent().add_child(bullet_instance)
			bullet_instance.position = global_position + point_vector
			bullet_instance.apply_impulse(Vector2.ZERO, point_vector * BULLET_FORCE)
			$AttackTimer.start()

func _on_HarvestTimer_timeout():
	var tile = buildings_tilemap.get_cellv(harvest_tile)
	buildings_tilemap.set_cellv(harvest_tile, -1)
	buildings_tilemap.update_dirty_quadrants()
	if tile == 16:
		wood += 10
		$GainCharges.play()
		emit_signal("wood_changed")
		emit_signal("trees_devoured")
	if tile == 0 or tile == 1 or tile == 2 or tile == 3 or tile == 4:
		$GainCharges.play()
		wood += 25
		emit_signal("building_devoured")
		emit_signal("wood_changed")
