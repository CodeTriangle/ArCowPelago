class_name ApConnectButton
extends TextureButton

@onready var mod_node = get_node("/root/ModLoader/CodeTriangle-Archipelago")
@onready var ap_client: CowApClient = mod_node.ap_client
@onready var ap_connect_panel: ApConnectPanel = mod_node.ap_connect_panel

@onready var star_counter: Label = $StarCounter
@onready var steak_counter: Label = $SteakCounter

var texture_gray = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/ap_logo_80_outline_gray.png")
var texture_colored = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/ap_logo_80_outline.png")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_color()

	pressed.connect(open_connect_panel)

	ap_client.connection_state_changed.connect(_on_connection_state_changed)
	ap_client.item_received.connect(_on_item_received)

	set_text_box_texts()
	_on_connection_state_changed(ap_client.connect_state, null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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

		star_counter.text = "%d out of %d" % [ap_client.current_stars, ap_client.goal_stars]

		if ap_client.slot_data["beefsanity"]:
			steak_counter.visible = true
			steak_counter.text = "%d out of %d" % [ap_client.current_steaks, ap_client.goal_steaks]


func _on_connection_state_changed(state: CowApClient.ConnectState, _error):
	if state == CowApClient.ConnectState.CONNECTED_TO_MULTIWORLD:
		set_text_box_texts()
	else:
		star_counter.visible = false
		steak_counter.visible = false


func _on_item_received(item_name: String, _item: Dictionary):
	if item_name == "Star" or item_name == "Steak":
		set_text_box_texts()
