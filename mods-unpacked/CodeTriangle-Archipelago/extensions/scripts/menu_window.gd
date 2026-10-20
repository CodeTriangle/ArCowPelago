extends "res://scripts/menu_window.gd"


const LOG_NAME := "CodeTriangle-Archipelago:menu_window"

var ap_connect_button: ApConnectButton
var ap_client: CowApClient

var trophy_texture: Texture2D = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/trophy.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	play_button.disabled = true

	var connect_button_scene = load("res://mods-unpacked/CodeTriangle-Archipelago/scenes/ap_connect_button.tscn")
	ap_connect_button = connect_button_scene.instantiate()
	add_child(ap_connect_button)

	ap_client = ap_connect_button.ap_client
	ap_client.item_received.connect(_on_item_received)

	bonus_levels_button.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var connected = ap_client.connect_state == CowApClient.ConnectState.CONNECTED_TO_MULTIWORLD
	level_select_button.disabled = not connected


func _on_item_received(_item_name: String, _item: Dictionary):
	if ap_client.timer != null and ap_client.timer.time_left > 0:
		return
	recalculate_level_buttons()


func add_star(parent: Node):
	var star_icon = TextureRect.new()
	star_icon.texture = star_filled
	star_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	star_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	star_icon.custom_minimum_size = Vector2(24, 24)
	star_icon.position = Vector2(-8, -8)
	star_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(star_icon)


func add_steak(parent: Node):
	var steak_icon = TextureRect.new()
	steak_icon.texture = steak_texture
	steak_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	steak_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	steak_icon.custom_minimum_size = Vector2(24, 24)
	steak_icon.position = Vector2(18, -8)
	steak_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(steak_icon)


func add_trophy(parent: Node):
	var trophy_icon = TextureRect.new()
	trophy_icon.texture = trophy_texture
	trophy_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trophy_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	trophy_icon.custom_minimum_size = Vector2(24, 24)
	trophy_icon.position = Vector2(60, -8)
	trophy_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(trophy_icon)


func refresh_level_select() -> void:
	super()
	if ap_client:
		recalculate_level_buttons()


func recalculate_level_buttons() -> void:
	var active_levels = levels
	if OS.has_feature("demo"):
		active_levels = demo_levels
	elif Global.is_ascended:
		active_levels = ascended_levels

	var index = 0
	for page: VBoxContainer in pages:
		for level_button: Button in page.get_children()[0].get_children():
			for node in level_button.get_children():
				level_button.remove_child(node)

			var number: int
			var level_type: String
			var pack: CowApClient.LevelPackInfo
			var item_id: int

			if index >= len(active_levels):
				continue
			var level_path = active_levels[index]
			var true_level_name = level_path.get_file().trim_suffix(".tscn")

			if true_level_name.begins_with("level_"):
				number = int(true_level_name.substr(6))
				if Global.is_ascended:
					pack = ap_client.ascended_levels
					level_type = "Ascended Level"
				else:
					pack = ap_client.levels
					level_type = "Level"
			elif true_level_name.begins_with("race_"):
				number = int(true_level_name.substr(5))
				pack = ap_client.races
				level_type = "Race"


			item_id = pack.get_unlock_item_id(number)

			if pack.has_all_stars(number):
				add_star(level_button)

			if pack.has_all_steaks(number):
				add_steak(level_button)

			level_button.disabled = ap_client.received_item_ids.get(item_id, 0) == 0
			if level_type == ap_client.goal_level_type and number == ap_client.goal_level_num:
				add_trophy(level_button)
				if (
					ap_client.current_stars < ap_client.goal_stars
					or ap_client.slot_data["beefsanity"] and ap_client.current_steaks < ap_client.goal_steaks
				):
					level_button.disabled = true

			ModLoaderLog.debug(
				level_type + " " + str(number) + " (id " + str(item_id) + "): " + str(not level_button.disabled),
				LOG_NAME
			)

			index += 1


func _on_level_select_button_pressed() -> void:
	recalculate_level_buttons()
	super()
