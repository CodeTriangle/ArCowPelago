class_name CowApClient
extends GodotApClient


const LEVEL_STEAK_AMOUNTS: Array[int] = [
	2,  3,  6,  4,  4,  3,  5, 10,  4,  3,
	4,  4,  3,  3,  2,  4,  5,  5,  2,  1,
	5,  7,  7,  4,  5,  7,  3, 10,  5,  9,
	7,  9,  5,  3,  6,  3,  3,  4,  5,  4,
	3,  6,  7,  4,  5,  6,  3,  5,  4,  3,
	4,  4,  4,  3,  5,  3,  3,  3,  2,  3,
	3,  3,  5,  4,  6,  4,  6,  3,  4,  3,
	3,  6,  4,  3,  4,  2,  3,  4,  4
]

const RACE_STEAK_AMOUNTS: Array[int] = [ 4, 5, 4, 5, 4, 7, 4, 3 ]

const ASCENDED_LEVEL_STEAK_AMOUNTS: Array[int] = [
	2, 3, 3, 2, 2,
	2, 2, 4, 2, 3,
	3, 3, 3, 3, 10,
	3, 4, 5, 4, 4,
]

const STEAK_STRIDE = 100


class LevelPackInfo:
	var client: CowApClient

	var base_unlock_id: int
	var base_clear_id: int
	var base_star_id: int
	var base_steak_id: int

	var steak_amounts: Array[int]

	func _init(
		a_client: CowApClient,
		index: int,
		a_steak_amounts: Array[int]
	) -> void:
		client = a_client
		base_unlock_id = 1000 + index * 1000
		base_clear_id = 1000 + index * 4000
		base_star_id = 2000 + index * 4000
		base_steak_id = 100000 + index * 100000
		steak_amounts = a_steak_amounts

	func get_unlock_item_id(level: int) -> int:
		return base_unlock_id + level

	func get_clear_location_id(level: int) -> int:
		return base_clear_id + level

	func get_star_low_location_id(level: int) -> int:
		return base_star_id + level * 3 + 1

	func get_steak_location_id(level: int, steak: int) -> int:
		return base_steak_id + level * STEAK_STRIDE + steak

	func has_all_stars(level: int) -> bool:
		var low = get_star_low_location_id(level) 
		for star_num in range(3):
			if not client.checked_locations.has(float(low + star_num)):
				return false
		return true

	func has_all_steaks(level: int) -> bool:
		for steak_num in range(1, steak_amounts[level - 1] + 1):
			if not client.checked_locations.has(float(get_steak_location_id(level, steak_num))):
				return false
		return true

var levels = LevelPackInfo.new(self, 0, LEVEL_STEAK_AMOUNTS)
var races = LevelPackInfo.new(self, 1, RACE_STEAK_AMOUNTS)
var ascended_levels = LevelPackInfo.new(self, 2, ASCENDED_LEVEL_STEAK_AMOUNTS)

var packs: Dictionary[String, LevelPackInfo] = {
	"level": levels,
	"race": races,
	"ascended_level": ascended_levels,
}

var goal_stars = 0
var goal_steaks = 0
var current_stars = 0
var current_steaks = 0

var goal_level_type: String
var goal_level_num: int

var timer: SceneTreeTimer
var deathlink_amnesty: int = 0


func _ready() -> void:
	super()
	item_received.connect(_cowap_on_item_received)
	connection_state_changed.connect(_cowap_on_connection_state_change)


func check_for_goal() -> bool:
	# legacy check -- only run if there is no goal level
	if goal_level_type == null and goal_level_num == null and current_stars >= goal_stars:
		if slot_data["beefsanity"] and current_steaks < goal_steaks:
			return false

		set_status(ApTypes.ClientStatus.CLIENT_GOAL)
		return true
	return false


func _cowap_on_connection_state_change(state: int, _error: int = 0):
	if state == ConnectState.CONNECTED_TO_MULTIWORLD:
		timer = get_tree().create_timer(0.5)

		var goal_level = slot_data.get("goal_level", null)

		if goal_level != null:
			goal_level_type = goal_level[0]
			goal_level_num = int(goal_level[1])

		goal_stars = int(slot_data["goal_stars"])
		goal_steaks = int(slot_data["goal_steaks"])
		current_stars = int(received_item_ids.get(int(data_package.item_name_to_id["Star"]), 0))
		current_steaks = int(received_item_ids.get(int(data_package.item_name_to_id["Steak"]), 0))


func _cowap_on_item_received(item_name: String, _item: Dictionary):
	if item_name == "Star":
		current_stars += 1
		check_for_goal()
	elif item_name == "Steak":
		current_steaks += 1
		check_for_goal()
