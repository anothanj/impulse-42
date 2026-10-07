extends StaticBody2D

@onready var trigger_area: Area2D = $TriggerArea
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var can_fire: bool = true

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if can_fire and body is RigidBody2D:
		can_fire = false
		var direction: Vector2 = transform.y
		body.apply_central_impulse(direction * 650.0)
		
		sprite_2d.play("default")
		await sprite_2d.animation_finished
		sprite_2d.frame = 0
		
		await get_tree().create_timer(0.3).timeout
		can_fire = true
