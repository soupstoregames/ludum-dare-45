extends Camera2D

var shake_amount = 0

func _process(delta):
	if shake_amount > 0:
		offset = Vector2(rand_range(-shake_amount, shake_amount),rand_range(-shake_amount, shake_amount))
		shake_amount -= 2.5 * delta
		if shake_amount < 0:
			shake_amount = 0