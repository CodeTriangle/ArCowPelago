class_name ApItemLabel
extends CanvasLayer


var ap_client: CowApClient
var label: Label
## Timer that starts when connected and stops 5 seconds later to account for items received in the initial burst
var tween: Tween


func _ready() -> void:
	ap_client = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_client
	label = $Label

	ap_client.item_received.connect(_on_item_received)


func _on_item_received(item_name: String, item: Dictionary):
	if ap_client.timer != null and ap_client.timer.time_left > 0:
		return
	if tween != null:
		tween.kill()

	var player_name = ap_client._resolve_player_name(item["player"])
	set_text("Received " + item_name + " from " + player_name)


func set_text(text: String):
	label.text = text 
	label.modulate.a = 1.0

	tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
