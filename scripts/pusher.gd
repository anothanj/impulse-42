extends RigidBody2D

@onready var kernel: RigidBody2D = $"../Kernel"
@export var move_force: float = 400.0
@export var max_speed: float = 150.0
@export var turn_speed: float = 8.0 

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not is_instance_valid(kernel):
		return

	var direction: Vector2 = (kernel.global_position - global_position).normalized()
	
	var angle: float = direction.angle()
	state.transform.basis_xform(Vector2.RIGHT)
	rotation = lerp_angle(rotation, angle, state.step * turn_speed)
	
	if state.linear_velocity.length() < max_speed:
		state.apply_force(transform.x * move_force)
