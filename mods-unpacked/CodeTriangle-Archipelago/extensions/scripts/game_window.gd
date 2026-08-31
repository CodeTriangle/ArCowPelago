extends "res://scripts/game_window.gd"

var ap_client: CowApClient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	ap_client = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_client

	ap_client.item_received.connect(_on_item_received)


func level_beaten():
	super()

	var current_level_path = levels[current_level_index]
	var true_level_name = current_level_path.get_file().trim_suffix(".tscn")

	var clear_loc
	var star_loc_base

	if true_level_name.begins_with("level_"):
		var num = int(true_level_name.trim_prefix("level_"))
		clear_loc = ap_client.get_level_clear_location_id(num)
		star_loc_base = ap_client.get_level_star_low_location_id(num)
	elif true_level_name.begins_with("race_"):
		var num = int(true_level_name.trim_prefix("race_"))
		clear_loc = ap_client.get_race_clear_location_id(num)
		star_loc_base = ap_client.get_race_star_low_location_id(num)

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
