extends RigidBody2D

var DAMAGE = 10

func super_charge():
	DAMAGE = 25
	$Sprite.visible = false
	$Sprite2.visible = true

func _on_Bullet_body_entered(body):
	$Sprite.queue_free()
	$Collision.queue_free()
	$Timer.queue_free()
	
	$ImpactSound.play()
	if body.has_method("apply_damage"):
		body.call("apply_damage", DAMAGE)

func _on_Timer_timeout():
	queue_free()

func _on_ImpactSound_finished():
	queue_free()
