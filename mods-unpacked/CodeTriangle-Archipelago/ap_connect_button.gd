class_name ApConnectButton
extends TextureButton

@onready var mod_node = get_node("/root/ModLoader/CodeTriangle-Archipelago")
@onready var ap_client: ApClient = mod_node.ap_client
@onready var ap_connect_panel: ApConnectPanel = mod_node.ap_connect_panel
var texture_gray = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/ap_logo_80_outline_gray.png")
var texture_colored = load("res://mods-unpacked/CodeTriangle-Archipelago/assets/ap_logo_80_outline.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_color()

	pressed.connect(open_connect_panel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_color()


func set_color():
	if ap_client.connect_state == ApClient.ConnectState.CONNECTED_TO_MULTIWORLD:
		texture_normal = texture_colored
	else:
		texture_normal = texture_gray


func open_connect_panel() -> void:
	print("open connect panel")
	ap_connect_panel.show_forced()
