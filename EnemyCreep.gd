extends KinematicBody2D

var movement = Vector2()
const HEALTH = 50
var current_health = HEALTH
var target = Vector2()
const DAMAGE = 5

signal killed

onready var player = get_tree().get_root().get_node("World/Navigation2D/Human")

func _ready():
	connect("killed", get_tree().get_root().get_node("World/ScoreKeeper"), "_on_Creep_killed")

func _physics_process(delta):
	move_to_player()

func move_to_player():
	var movement_vector = player.global_position - global_position
	if movement_vector.length() < 4:
		if $AttackTimer.time_left <= 0:
			player.call("apply_damage", DAMAGE)
			$AttackSound.pitch_scale = rand_range(0.8, 1.25)
			$AttackSound.play()
			$AttackTimer.start()
		return
	movement = movement_vector.normalized() * 5
	movement = move_and_slide(movement)

func apply_damage(amount):
	current_health -= amount
	if current_health <= 0:
		die()
		return
	if current_health < HEALTH:
		update_health_bar()

func die():
	emit_signal("killed")
	queue_free()
	
func update_health_bar():
	$Healthbar.show()
	var frame = floor((float(current_health) / HEALTH) * 10)
	$Healthbar.frame = frame
