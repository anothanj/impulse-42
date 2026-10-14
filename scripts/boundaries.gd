extends Area2D

@export var enemies: Node2D
@export var kernel: RigidBody2D
@export var game: Node2D
@export var game_over: Label

func _on_body_exited(body: Node2D) -> void:
	body.queue_free()
	if body == kernel:
		game_over.show()
