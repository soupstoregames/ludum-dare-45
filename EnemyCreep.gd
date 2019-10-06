extends KinematicBody2D

const HEALTH = 35
var current_health = HEALTH

func apply_damage(amount):
	current_health -= amount
	if current_health <= 0:
		die()
		return
	if current_health < HEALTH:
		update_health_bar()


func die():
	queue_free()
	
func update_health_bar():
	$Healthbar.show()
	var frame = floor((float(current_health) / HEALTH) * 10)
	$Healthbar.frame = frame