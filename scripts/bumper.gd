extends StaticBody2D

@export var bounce_impulse: float = 900.0

@onready var bump_area: Area2D = $BumpArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cooldown_timer: Timer = $CooldownTimer

var can_bump: bool = true

func _on_bump_area_body_entered(_body: Node2D) -> void:
	if can_bump:
		_pop()

func _pop() -> void:
	var hit: bool = false
	for body in bump_area.get_overlapping_bodies():
		if body is RigidBody2D:
			var dir: Vector2 = (body.global_position - global_position).normalized()
			body.apply_central_impulse(dir * bounce_impulse)
			hit = true

	if not hit:
		return

	can_bump = false
	sprite_2d.scale = Vector2(1.35, 1.35)
	sprite_2d.modulate = Color(0.6, 0.6, 0.6)
	create_tween().tween_property(sprite_2d, "scale", Vector2.ONE, 0.18)
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	can_bump = true
	sprite_2d.modulate = Color.WHITE
	if bump_area.has_overlapping_bodies():
		_pop()

