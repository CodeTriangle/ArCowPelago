class_name ApConnectButton
extends TextureButton

@onready var mod_node = get_node("/root/ModLoader/CodeTriangle-Archipelago")
@onready var ap_client: CowApClient = mod_node.ap_client
@onready var ap_connect_panel: ApConnectPanel = mod_node.ap_connect_panel

@onready var star_counter: Label = $StarCounter
@onready var steak_counter: Label = $SteakCounter

var texture_gray = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/ap_logo_80_outline_gray.png")
var texture_colored = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/ap_logo_80_outline.png")


var goal_stars = 0
var goal_steaks = 0
var current_stars = 0
var current_steaks = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_color()

	pressed.connect(open_connect_panel)

	ap_client.connection_state_changed.connect(_on_connection_state_changed)
	ap_client.item_received.connect(_on_item_received)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_color()


func set_color():
	if ap_client.connect_state == CowApClient.ConnectState.CONNECTED_TO_MULTIWORLD:
		texture_normal = texture_colored
	else:
		texture_normal = texture_gray


func open_connect_panel() -> void:
	print("open connect panel")
	ap_connect_panel.show_forced()


func set_text_box_texts() -> void:
	var active = ap_client.connect_state == CowApClient.ConnectState.CONNECTED_TO_MULTIWORLD

	if active:
		star_counter.visible = true

		star_counter.text = "%d out of %d" % [current_stars, goal_stars]

		if ap_client.slot_data["beefsanity"]:
			steak_counter.visible = true
			steak_counter.text = "%d out of %d" % [current_steaks, goal_steaks]


func check_for_goal() -> bool:
	if current_stars >= goal_stars:
		if ap_client.slot_data["beefsanity"] and current_steaks < goal_steaks:
			return false

		ap_client.set_status(ApTypes.ClientStatus.CLIENT_GOAL)
		return true
	return false


func _on_connection_state_changed(state: CowApClient.ConnectState, _error):
	if state == CowApClient.ConnectState.CONNECTED_TO_MULTIWORLD:
		print("CONNECTED_TO_MULTIWORLD")
		goal_stars = int(ap_client.slot_data["goal_stars"])
		goal_steaks = int(ap_client.slot_data["goal_steaks"])
		set_text_box_texts()
	else:
		star_counter.visible = false
		steak_counter.visible = false

func _on_item_received(item_name: String, _item: Dictionary):
	print("ITEM RECEIVED")
	if item_name == "Star":
		current_stars += 1
		set_text_box_texts()
		check_for_goal()
	elif item_name == "Steak":
		current_steaks += 1
		set_text_box_texts()
		check_for_goal()
