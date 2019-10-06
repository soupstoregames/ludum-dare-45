extends KinematicBody2D

export (int) var speed = 100
var movement = Vector2()

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	rotate_turret()
	move_base()
	
	
func rotate_turret():
	var turretVector = get_global_mouse_position() - position
	turretVector = turretVector.normalized()
	$Turret.rotation = turretVector.angle()
	
func move_base():
	movement = Vector2()
	
	if Input.is_action_pressed("move_up"):
		movement.y += -1
	if Input.is_action_pressed("move_down"):
		movement.y += 1
	if Input.is_action_pressed("move_left"):
		movement.x += -1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
		
	movement = movement.normalized() * speed
	
	movement = move_and_slide(movement)