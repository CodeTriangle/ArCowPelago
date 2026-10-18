extends "res://scripts/game_window.gd"

var ap_client: CowApClient
@onready var spike_ball: PackedScene = load("res://scenes/spiked_ball_rigid_body.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	ap_client = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_client

	ap_client.item_received.connect(_on_item_received)


func _on_next_button_pressed():
	pass


func level_beaten():
	super()

	var current_level_path = levels[current_level_index]
	var true_level_name = current_level_path.get_file().trim_suffix(".tscn")

	var pack: CowApClient.LevelPackInfo
	var num

	if true_level_name.begins_with("level_"):
		num = int(true_level_name.trim_prefix("level_"))
		pack = ap_client.ascended_levels if Global.is_ascended else ap_client.levels
	elif true_level_name.begins_with("race_"):
		num = int(true_level_name.trim_prefix("race_"))
		pack = ap_client.races

	var clear_loc = pack.get_clear_location_id(num)
	var star_loc_base = pack.get_star_low_location_id(num)

	ap_client.check_location(clear_loc)

	var thresholds = star_thresholds.get(true_level_name, [0.0, 0.0, 0.0])

	var display_time = floor(level_time * 100.0) / 100.0

	if display_time <= thresholds[2]:
		ap_client.check_location(star_loc_base + 0)
	if display_time <= thresholds[1]:
		ap_client.check_location(star_loc_base + 1)
	if display_time <= thresholds[0]:
		ap_client.check_location(star_loc_base + 2)

	next_button.disabled = true


func _on_item_received(item_name: String, _item: Dictionary):
	if item_name == "Milk Trap":
		get_tree().call_group("player", "get_milked")
	if item_name == "Spike Ball Trap":
		var player_pos: Vector3 = player.position
		var player_vel: Vector3 = player.velocity
		var ball: RigidBody3D = spike_ball.instantiate()
		var pos = player_pos - Vector3(0, -30.0, 0)
		ball.position = pos
		ball.add_to_group("spiked_rigid")
		ball.linear_velocity = player_vel + Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10))
		get_tree().current_scene.add_child(ball)
	if item_name == "Moo":
		SoundManager.play_sfx("moo")
