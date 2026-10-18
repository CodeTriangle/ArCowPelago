extends "res://scripts/steak.gd"


const LOG_NAME := "CodeTriangle-Archipelago:Steak"


var ap_client: CowApClient
var ap_steak_number: int = -1

func _ready() -> void:
	ap_client = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_client

func _on_body_entered(body: Node3D) -> void:
	super(body)
	if body.has_method("collect_steak"):
		if body.is_dead:
			return

		var steak_id = get_tree().get_nodes_in_group("steaks").find(self) + 1
		print(get_tree().get_first_node_in_group("steaks"))

		if (steak_id == 0):
			ModLoaderLog.error("This steak was not found in the steaks group!", LOG_NAME)

		var game_window = get_node("/root/GameWindow")
		var current_level_path = game_window.levels[game_window.current_level_index]
		var true_level_name = current_level_path.get_file().trim_suffix(".tscn")

		var pack: CowApClient.LevelPackInfo
		var num

		if true_level_name.begins_with("level_"):
			num = int(true_level_name.trim_prefix("level_"))
			pack = ap_client.ascended_levels if Global.is_ascended else ap_client.levels
		elif true_level_name.begins_with("race_"):
			num = int(true_level_name.trim_prefix("race_"))
			pack = ap_client.races

		var steak_loc = pack.get_steak_location_id(num, steak_id)

		ap_client.check_location(steak_loc)
