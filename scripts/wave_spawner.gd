extends Node2D

signal wave_cleared

const WAVES: Array[Dictionary] = [
	{"pushers": 5, "juggernauts": 0, "interval": 1.4, "duration": 18.0, "spawns": [0, 1, 4, 5]},
	{"pushers": 8, "juggernauts": 0, "interval": 1.2, "duration": 20.0, "spawns": [2, 3, 6, 7]},
	{"pushers": 6, "juggernauts": 2, "interval": 1.2, "duration": 22.0, "spawns": [0, 1, 2, 3]},
	{"pushers": 10, "juggernauts": 3, "interval": 1.0, "duration": 24.0, "spawns": [4, 5, 6, 7]},
	{"pushers": 12, "juggernauts": 5, "interval": 0.85, "duration": 26.0, "spawns": [0, 1, 2, 3, 4, 5, 6, 7]},
]

@export var enemies_container: Node2D
@export var kernel: Node2D
@export var pusher_scene: PackedScene
@export var juggernaut_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_points: Node2D = $SpawnPoints

var spawn_queue: Array[PackedScene] = []
var active_spawns: Array = []
var wave_running: bool = false
var pulse_time: float = 0.0

func _process(delta: float) -> void:
	if not wave_running:
		pulse_time += delta * 5.0
		spawn_points.modulate.a = 0.6 + 0.35 * sin(pulse_time)

func get_total_waves() -> int:
	return WAVES.size()

func is_wave_running() -> bool:
	return wave_running

func get_time_left() -> float:
	return wave_timer.time_left

func preview_wave(wave_number: int) -> void:
	var markers: Array[Node] = spawn_points.get_children()
	if wave_number < 1 or wave_number > WAVES.size():
		for marker in markers:
			(marker as CanvasItem).visible = false
		return
	var next_spawns: Array = WAVES[wave_number - 1]["spawns"]
	for i in markers.size():
		(markers[i] as CanvasItem).visible = i in next_spawns

func start_wave(wave_number: int) -> void:
	var data: Dictionary = WAVES[wave_number - 1]
	spawn_queue.clear()
	for i in data["pushers"]:
		spawn_queue.append(pusher_scene)
	for i in data["juggernauts"]:
		spawn_queue.append(juggernaut_scene)
	spawn_queue.shuffle()

	active_spawns = data["spawns"]
	wave_running = true
	spawn_points.modulate.a = 0.35
	wave_timer.start(data["duration"])
	spawn_timer.wait_time = data["interval"]
	_spawn_next()
	if not spawn_queue.is_empty():
		spawn_timer.start()
	else:
		preview_wave(0)

func stop() -> void:
	wave_running = false
	spawn_queue.clear()
	spawn_timer.stop()
	wave_timer.stop()
	preview_wave(0)

func _on_spawn_timer_timeout() -> void:
	_spawn_next()
	if spawn_queue.is_empty():
		spawn_timer.stop()
		preview_wave(0)

func _on_wave_timer_timeout() -> void:
	if not wave_running:
		return
	wave_running = false
	spawn_queue.clear()
	spawn_timer.stop()
	preview_wave(0)
	for enemy in enemies_container.get_children():
		enemy.queue_free()
	wave_cleared.emit()

func _spawn_next() -> void:
	if spawn_queue.is_empty() or not is_instance_valid(kernel):
		return
	var scene: PackedScene = spawn_queue.pop_back()
	var enemy: RigidBody2D = scene.instantiate() as RigidBody2D
	var markers: Array[Node] = spawn_points.get_children()
	var marker: Node2D = markers[active_spawns.pick_random()] as Node2D
	enemy.global_position = marker.global_position
	enemy.rotation = (kernel.global_position - marker.global_position).angle()
	enemy.target = kernel
	enemy.tree_exited.connect(_on_enemy_tree_exited)
	enemies_container.add_child(enemy)

func _on_enemy_tree_exited() -> void:
	if not is_inside_tree() or not wave_running or not spawn_queue.is_empty():
		return
	for child in enemies_container.get_children():
		if not child.is_queued_for_deletion():
			return
	wave_running = false
	wave_timer.stop()
	preview_wave(0)
	wave_cleared.emit()
