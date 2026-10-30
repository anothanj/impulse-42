extends RigidBody2D

func _physics_process(_delta: float) -> void:
	for body in get_colliding_bodies():
		if body is StaticBody2D:
			body.queue_free()
