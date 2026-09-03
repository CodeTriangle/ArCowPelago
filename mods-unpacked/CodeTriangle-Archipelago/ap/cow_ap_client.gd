class_name CowApClient
extends GodotApClient


const BASE_LEVEL_UNLOCK_ID = 1000
const BASE_RACE_UNLOCK_ID = 2000

const BASE_LEVEL_CLEAR_ID = 1000
const BASE_LEVEL_STAR_ID = 2000
const BASE_RACE_CLEAR_ID = 5000
const BASE_RACE_STAR_ID = 6000

const BASE_LEVEL_STEAK_ID = 100000
const BASE_RACE_STEAK_ID = 200000

const STEAK_STRIDE = 100

const LEVEL_STEAK_AMOUNTS = [
	2,  3,  6,  4,  4,  3,  5, 10,  4,  3,
	4,  4,  3,  3,  2,  4,  5,  5,  2,  1,
	5,  7,  7,  4,  5,  7,  3, 10,  5,  9,
	7,  9,  5,  3,  6,  3,  3,  4,  5,  4,
	3,  6,  7,  4,  5,  6,  3,  5,  4,  3,
	4,  4,  4,  3,  5,  3,  3,  3,  2,  3,
	3,  3,  5,  4,  6,  4,  6,  3,  4,  3,
	3,  6,  4,  3,  4,  2,  3,  4,  4
]

const RACE_STEAK_AMOUNTS = [ 4, 5, 4, 5, 4, 7, 4, 3 ]


var timer: SceneTreeTimer
var deathlink_amnesty: int = 0


func get_level_unlock_item_id(level: int) -> int:
	return BASE_LEVEL_UNLOCK_ID + level


func get_race_unlock_item_id(level: int) -> int:
	return BASE_RACE_UNLOCK_ID + level


func get_level_clear_location_id(level: int) -> int:
	return BASE_LEVEL_CLEAR_ID + level


func get_race_clear_location_id(race: int) -> int:
	return BASE_RACE_CLEAR_ID + race


func get_level_star_low_location_id(level: int) -> int:
	return BASE_LEVEL_STAR_ID + level * 3 + 1


func get_race_star_low_location_id(race: int) -> int:
	return BASE_RACE_STAR_ID + race * 3 + 1


func get_level_steak_location_id(level: int, steak: int) -> int:
	return BASE_LEVEL_STEAK_ID + level * STEAK_STRIDE + steak


func get_race_steak_location_id(race: int, steak: int) -> int:
	return BASE_RACE_STEAK_ID + race * STEAK_STRIDE + steak


func has_all_stars_in_level(level: int) -> bool:
	var low = get_level_star_low_location_id(level) 
	for star_num in range(3):
		if not checked_locations.has(float(low + star_num)):
			return false
	return true


func has_all_stars_in_race(race: int) -> bool:
	var low = get_race_star_low_location_id(race)
	for star_num in range(3):
		if not checked_locations.has(float(low + star_num)):
			return false
	return true


func has_all_steaks_in_level(level: int) -> bool:
	for steak_num in range(1, LEVEL_STEAK_AMOUNTS[level - 1] + 1):
		if not checked_locations.has(float(get_level_steak_location_id(level, steak_num))):
			return false
	return true


func has_all_steaks_in_race(race: int) -> bool:
	for steak_num in range(1, RACE_STEAK_AMOUNTS[race - 1] + 1):
		if not checked_locations.has(float(get_race_steak_location_id(race, steak_num))):
			return false
	return true


func _set_connection_state(state: int, error: int = 0):
	super(state, error)
	if state == ConnectState.CONNECTED_TO_MULTIWORLD:
		timer = get_tree().create_timer(0.5)
