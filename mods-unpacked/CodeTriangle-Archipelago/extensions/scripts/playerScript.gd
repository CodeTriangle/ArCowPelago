extends "res://scripts/playerScript.gd"


@onready var ap_client: CowApClient = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_client
@onready var ap_item_label: ApItemLabel = get_node("/root/ModLoader/CodeTriangle-Archipelago").ap_item_label

var receiving_deathlink: bool = false
var deaths_sent: int = 0


func _ready() -> void:
	ap_client.bounced_received.connect(_on_bounced_received)


func die():
	super()
	if not receiving_deathlink and ap_client.player_tags.has("DeathLink"):
		deaths_sent += 1
		if deaths_sent >= ap_client.deathlink_amnesty:
			print("Sending deathlink :3")
			ap_client.send_deathlink(ap_client.player, "Cow is dead.")
			deaths_sent = 0


func deathlink():
	receiving_deathlink = true
	die()
	receiving_deathlink = false


func _on_bounced_received(data):
	if data["tags"].has("DeathLink") and data["data"].get("source", ap_client.player) != ap_client.player:
		deathlink()
		var cause = data["data"].get("cause", null)
		if cause:
			ap_item_label.set_text(cause)
		else:
			ap_item_label.set_text("Received Death from %s" % data["data"].get("source", "a friend"))
