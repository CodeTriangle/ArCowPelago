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


var timer: SceneTreeTimer


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


func _set_connection_state(state: int, error: int = 0):
	super(state, error)
	if state == ConnectState.CONNECTED_TO_MULTIWORLD:
		timer = get_tree().create_timer(0.5)
