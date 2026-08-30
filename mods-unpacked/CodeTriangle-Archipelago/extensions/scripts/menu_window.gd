extends "res://scripts/menu_window.gd"

var ap_connect_button: ApConnectButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	play_button.disabled = true
	level_select_button.disabled = true

	ap_connect_button = ApConnectButton.new()
	ap_connect_button.position = Vector2(535.0, 50.0)
	add_child(ap_connect_button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
