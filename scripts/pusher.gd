extends RigidBody2D

@export var move_force: float = 280.0
@export var max_speed: float = 130.0
@export var turn_speed: float = 7.0
@export var credit_value: int = 25

var target: Node2D

func _ready() -> void:
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("kernel") as Node2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not is_instance_valid(target):
		return

	var direction: Vector2 = (target.global_position - state.transform.origin).normalized()
	var new_angle: float = lerp_angle(state.transform.get_rotation(), direction.angle(), state.step * turn_speed)
	state.transform = Transform2D(new_angle, state.transform.origin)
	state.angular_velocity = 0.0

	if state.linear_velocity.dot(state.transform.x) < max_speed:
		state.apply_central_force(state.transform.x * move_force)
