extends Node2D

signal tower_selected(index: int)

@export var tilemap: TileMapLayer
@export var defenders_container: Node2D
@export var enemies_container: Node2D
@export var kernel: RigidBody2D
@export var game_manager: Node
@export var tower_scenes: Array[PackedScene] = []
@export var tower_textures: Array[Texture2D] = []
@export var tower_costs: Array[int] = [50, 25]
@export var tower_offsets: Array[Vector2] = [Vector2(0, 16), Vector2.ZERO]
@export var kernel_exclusion_radius: float = 72.0

@onready var ghost_preview: Node2D = $GhostPreview
@onready var ghost_sprite: Sprite2D = $GhostPreview/Sprite2D

var occupied_cells: Dictionary = {}
var selected_tower: int = 0

func _ready() -> void:
	select_tower(0)

func _process(_delta: float) -> void:
	_update_ghost_position()

func _unhandled_input(event: InputEvent) -> void:
	if not game_manager.can_build():
		return

	if event.is_action_pressed("select_tower_1"):
		select_tower(0)
	elif event.is_action_pressed("select_tower_2"):
		select_tower(1)
	elif event.is_action_pressed("rotate_tower"):
		ghost_preview.rotation_degrees = fmod(ghost_preview.rotation_degrees + 90.0, 360.0)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place_tower()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			ghost_preview.visible = not ghost_preview.visible

func select_tower(index: int) -> void:
	if index < 0 or index >= tower_scenes.size():
		return
	selected_tower = index
	ghost_sprite.texture = tower_textures[index]
	ghost_sprite.offset = tower_offsets[index]
	if index == 1:
		ghost_preview.rotation_degrees = 0.0
	ghost_preview.visible = true
	tower_selected.emit(index)

func _update_ghost_position() -> void:
	if not ghost_preview.visible or not is_instance_valid(tilemap):
		return

	var cell: Vector2i = tilemap.local_to_map(get_global_mouse_position())
	var snapped_pos: Vector2 = tilemap.map_to_local(cell)
	ghost_preview.global_position = snapped_pos

	if _is_position_valid(cell, snapped_pos):
		ghost_sprite.modulate = Color(0.2, 1.0, 0.2, 0.6)
	else:
		ghost_sprite.modulate = Color(1.0, 0.2, 0.2, 0.6)

func _is_position_valid(cell: Vector2i, world_pos: Vector2) -> bool:
	if not game_manager.can_build() or not game_manager.can_afford(tower_costs[selected_tower]):
		return false
	if tilemap.get_cell_source_id(cell) == -1 or occupied_cells.has(cell):
		return false
	if is_instance_valid(kernel) and world_pos.distance_to(kernel.global_position) < kernel_exclusion_radius:
		return false
	for enemy: Node2D in enemies_container.get_children():
		if world_pos.distance_to(enemy.global_position) < 24.0:
			return false
	return true

func _try_place_tower() -> void:
	if not ghost_preview.visible:
		return

	var cell: Vector2i = tilemap.local_to_map(get_global_mouse_position())
	var snapped_pos: Vector2 = tilemap.map_to_local(cell)
	if not _is_position_valid(cell, snapped_pos):
		return

	if not game_manager.spend_credits(tower_costs[selected_tower]):
		return

	var new_tower: Node2D = tower_scenes[selected_tower].instantiate() as Node2D
	new_tower.global_position = snapped_pos
	new_tower.rotation_degrees = ghost_preview.rotation_degrees
	defenders_container.add_child(new_tower)
	occupied_cells[cell] = new_tower
	new_tower.tree_exited.connect(func() -> void: occupied_cells.erase(cell))

func _on_game_ended(_victory: bool) -> void:
	ghost_preview.visible = false
