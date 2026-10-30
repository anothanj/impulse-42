extends CanvasLayer

@export var game_manager: Node
@export var placement_manager: Node2D
@export var wave_spawner: Node2D

@onready var credits_label: Label = %CreditsLabel
@onready var wave_label: Label = %WaveLabel
@onready var status_label: Label = %StatusLabel
@onready var start_wave_button: Button = %StartWaveButton
@onready var btn_piston: Button = %BtnPiston
@onready var btn_bumper: Button = %BtnBumper
@onready var end_overlay: Control = %EndOverlay
@onready var end_title: Label = %EndTitle
@onready var end_subtext: Label = %EndSubtext

func _process(_delta: float) -> void:
	if is_instance_valid(wave_spawner) and wave_spawner.is_wave_running():
		status_label.text = "Survive: %ds" % ceil(wave_spawner.get_time_left())

func _on_credits_changed(amount: int) -> void:
	credits_label.text = "Credits: " + str(amount)
	btn_piston.disabled = amount < 50
	btn_bumper.disabled = amount < 25

func _on_wave_changed(wave: int, total: int, active: bool) -> void:
	wave_label.text = "Wave: " + str(wave) + " / " + str(total)
	if not active:
		status_label.text = "Build Phase"
	start_wave_button.visible = not active

func _on_tower_selected(index: int) -> void:
	btn_piston.modulate = Color(1.2, 1.2, 0.7) if index == 0 else Color.WHITE
	btn_bumper.modulate = Color(1.2, 1.2, 0.7) if index == 1 else Color.WHITE

func _on_game_ended(victory: bool) -> void:
	start_wave_button.visible = false
	status_label.text = "Victory!" if victory else "Defeat"
	end_title.text = "VICTORY!" if victory else "DEFEAT"
	end_title.modulate = Color(0.3, 1.0, 0.4) if victory else Color(1.0, 0.3, 0.3)
	end_subtext.text = "All enemy waves repelled!" if victory else "The Kernel fell into the Void!"
	end_overlay.visible = true

func _on_start_wave_button_pressed() -> void:
	game_manager.start_next_wave()

func _on_btn_piston_pressed() -> void:
	placement_manager.select_tower(0)

func _on_btn_bumper_pressed() -> void:
	placement_manager.select_tower(1)

func _on_restart_button_pressed() -> void:
	game_manager.restart_game()
