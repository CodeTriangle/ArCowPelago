class_name ApItemLabel
extends CanvasLayer


var ap_client: CowApClient
var label: Label
## Timer that starts when connected and stops 5 seconds later to account for items received in the initial burst
var timer: SceneTreeTimer
var tween: Tween


func _ready() -> void:
	ap_client = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_client
	label = $Label

	ap_client.item_received.connect(_on_item_received)


func _on_item_received(item_name: String, item: Dictionary):
	if ap_client.timer != null and ap_client.timer.time_left > 0:
		return
	if timer != null:
		timer.timeout.disconnect(_on_timer_timeout)
		timer = null
	if tween != null:
		tween.kill()

	label.text = "Received " + item_name + " from " + ap_client.players[item["player"]]["name"]
	label.modulate.a = 1.0

	timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout():
	tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
