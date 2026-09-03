extends "res://scripts/menu_window.gd"

var ap_connect_button: ApConnectButton
var ap_client: CowApClient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	play_button.disabled = true

	var connect_button_scene = load("res://mods-unpacked/CodeTriangle-Archipelago/scenes/ap_connect_button.tscn")
	ap_connect_button = connect_button_scene.instantiate()
	ap_connect_button.position = Vector2(535.0, 50.0)
	add_child(ap_connect_button)

	ap_client = ap_connect_button.ap_client
	ap_client.item_received.connect(_on_item_received)

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


func recalculate_level_buttons() -> void:
	for page: VBoxContainer in pages:
		for level_button: Button in page.get_children()[0].get_children():
			for node in level_button.get_children():
				level_button.remove_child(node)
			var button_name = level_button.name

			var number
			var item_id

			if button_name.begins_with("Level"):
				number = int(button_name.substr(5))
				item_id = ap_client.get_level_unlock_item_id(number)

				if ap_client.has_all_stars_in_level(number):
					add_star(level_button)

				if ap_client.has_all_steaks_in_level(number):
					add_steak(level_button)
			elif button_name.begins_with("Race"):
				number = int(button_name.substr(4))
				item_id = ap_client.get_race_unlock_item_id(number)

				if ap_client.has_all_stars_in_race(number):
					add_star(level_button)

				if ap_client.has_all_steaks_in_race(number):
					add_steak(level_button)

			level_button.disabled = ap_client.received_item_ids.get(item_id, 0) == 0


func _on_level_select_button_pressed() -> void:
	recalculate_level_buttons()
	super()
