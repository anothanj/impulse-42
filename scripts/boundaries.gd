extends Area2D

signal kernel_fell
signal enemy_fell(credits: int)

func _on_body_exited(body: Node2D) -> void:
	if not is_inside_tree() or body.is_queued_for_deletion() or body.get_meta("falling", false):
		return

	body.set_meta("falling", true)
	body.set_deferred("collision_layer", 0)
	body.set_deferred("collision_mask", 0)

	if body.is_in_group("kernel"):
		kernel_fell.emit()
	elif "credit_value" in body:
		enemy_fell.emit(body.credit_value)

	var sprite: Node2D = body.get_node_or_null("Sprite2D") as Node2D
	if sprite:
		var tween: Tween = body.create_tween().set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(body.queue_free)
	else:
		body.queue_free()
