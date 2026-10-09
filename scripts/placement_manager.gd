extends Node2D

@export var tilemap: TileMapLayer
@export var defenders_container: Node2D
@export var kernel: RigidBody2D
@export var piston_scene: PackedScene
@export var kernel_exclusion_radius: float = 64.0

@onready var ghost_preview: Node2D = $GhostPreview
@onready var ghost_sprite: AnimatedSprite2D = $GhostPreview/Sprite2D

var occupied_cells: Dictionary = {}

func _process(_delta: float) -> void:
	_update_ghost_position()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_tower"):
		_rotate_ghost()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place_piston()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			ghost_preview.visible = not ghost_preview.visible

func _update_ghost_position() -> void:
	if not ghost_preview.visible or not is_instance_valid(tilemap):
		return

	var cell: Vector2i = _get_mouse_cell()
	var snapped_pos: Vector2 = tilemap.map_to_local(cell)

	ghost_preview.global_position = snapped_pos

	if _is_position_valid(cell, snapped_pos):
		ghost_sprite.modulate = Color(0.2, 1.0, 0.2, 0.6)
	else:
		ghost_sprite.modulate = Color(1.0, 0.2, 0.2, 0.6)

func _rotate_ghost() -> void:
	ghost_preview.rotation_degrees = fmod(ghost_preview.rotation_degrees + 90.0, 360.0)

func _is_position_valid(cell: Vector2i, world_pos: Vector2) -> bool:
	if tilemap.get_cell_source_id(cell) == -1:
		return false

	if occupied_cells.has(cell):
		return false

	if is_instance_valid(kernel) and world_pos.distance_to(kernel.global_position) < kernel_exclusion_radius:
		return false

	return true

func _try_place_piston() -> void:
	if not ghost_preview.visible:
		return

	var cell: Vector2i = _get_mouse_cell()
	var snapped_pos: Vector2 = tilemap.map_to_local(cell)

	if not _is_position_valid(cell, snapped_pos):
		return

	var new_piston = piston_scene.instantiate() as Node2D
	new_piston.global_position = snapped_pos
	new_piston.rotation_degrees = ghost_preview.rotation_degrees

	defenders_container.add_child(new_piston)
	occupied_cells[cell] = true

func _get_mouse_cell() -> Vector2i:
	return tilemap.local_to_map(get_global_mouse_position())
