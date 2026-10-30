extends Node

signal credits_changed(amount: int)
signal wave_changed(current_wave: int, total_waves: int, active: bool)
signal game_ended(victory: bool)

enum State { BUILDING, WAVE_ACTIVE, ENDED }

@export var starting_credits: int = 150
@export var wave_clear_bonus: int = 50
@export var wave_spawner: Node2D

var credits: int = 0
var current_wave: int = 0
var state: State = State.BUILDING

func _ready() -> void:
	credits = starting_credits
	credits_changed.emit(credits)
	wave_changed.emit(current_wave, wave_spawner.get_total_waves(), false)
	wave_spawner.preview_wave(1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start_wave") and state == State.BUILDING:
		start_next_wave()

func can_build() -> bool:
	return state != State.ENDED

func can_afford(cost: int) -> bool:
	return credits >= cost

func spend_credits(cost: int) -> bool:
	if not can_afford(cost):
		return false
	credits -= cost
	credits_changed.emit(credits)
	return true

func add_credits(amount: int) -> void:
	credits += amount
	credits_changed.emit(credits)

func start_next_wave() -> void:
	if state != State.BUILDING:
		return
	current_wave += 1
	state = State.WAVE_ACTIVE
	wave_changed.emit(current_wave, wave_spawner.get_total_waves(), true)
	wave_spawner.start_wave(current_wave)

func _on_boundaries_enemy_fell(reward: int) -> void:
	if state != State.ENDED:
		add_credits(reward)

func _on_boundaries_kernel_fell() -> void:
	if state == State.ENDED:
		return
	state = State.ENDED
	wave_spawner.stop()
	game_ended.emit(false)

func _on_wave_spawner_wave_cleared() -> void:
	if state != State.WAVE_ACTIVE:
		return
	if current_wave >= wave_spawner.get_total_waves():
		state = State.ENDED
		game_ended.emit(true)
	else:
		add_credits(wave_clear_bonus)
		state = State.BUILDING
		wave_changed.emit(current_wave, wave_spawner.get_total_waves(), false)
		wave_spawner.preview_wave(current_wave + 1)

func restart_game() -> void:
	get_tree().reload_current_scene()
