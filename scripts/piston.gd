extends StaticBody2D

@export var impulse_force: float = 1400.0

@onready var trigger_area: Area2D = $TriggerArea
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var cooldown_timer: Timer = $CooldownTimer

var can_fire: bool = true

func _on_trigger_area_body_entered(_body: Node2D) -> void:
	if can_fire:
		_strike()

func _strike() -> void:
	var direction: Vector2 = transform.y
	var hit: bool = false

	for body in trigger_area.get_overlapping_bodies():
		if body is RigidBody2D:
			body.apply_central_impulse(direction * impulse_force)
			hit = true

	if not hit:
		return

	can_fire = false
	sprite_2d.play("default")
	cooldown_timer.start()

func _on_sprite_2d_animation_finished() -> void:
	sprite_2d.frame = 0

func _on_cooldown_timer_timeout() -> void:
	can_fire = true
	if trigger_area.has_overlapping_bodies():
		_strike()
