extends Node


const DIR := "CodeTriangle-Archipelago"
const LOG_NAME := "CodeTriangle-Archipelago:Main"
const CONFIG_PATH = "user://ap_connect.json"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""
var ap_client: CowApClient
var ap_ws_connection: ApWebSocketConnection
var ap_connect_panel: ApConnectPanel
var ap_overlay

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(DIR)
	# Add extensions
	install_script_extensions()
	# Add translations
	add_translations()


func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/menu_window.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/game_window.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/steak.gd"))
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/playerScript.gd"))


func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")
	# ModLoaderMod.add_translation(translations_dir_path.path_join(...))


func _ready() -> void:
	var config_data = {"ap_server": "", "ap_player": "", "ap_password": ""}

	if FileAccess.file_exists(CONFIG_PATH):
		var f = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed and typeof(parsed) == TYPE_DICTIONARY:
				config_data = parsed
				ModLoaderLog.info("Loaded config from %s" % CONFIG_PATH, LOG_NAME)
			else:
				ModLoaderLog.warning("Failed to parse config at %s" % CONFIG_PATH, LOG_NAME)
		else:
			ModLoaderLog.warning("Could not open config file at %s" % CONFIG_PATH, LOG_NAME)
	else:
		ModLoaderLog.info("No config file found at %s, skipping auto-connect." % CONFIG_PATH, LOG_NAME)

	var client_config = {
		"ap_server": config_data.get("ap_server", ""),
		"ap_player": config_data.get("ap_player", ""),
		"ap_password": config_data.get("ap_password", ""),
	}

	ap_ws_connection = ApWebSocketConnection.new()
	add_child(ap_ws_connection)

	ap_client = CowApClient.new(ap_ws_connection, client_config)
	add_child(ap_client)

	var panel_scene: PackedScene = load("res://mods-unpacked/CodeTriangle-Archipelago/scenes/ap_connect_panel.tscn")
	ap_connect_panel = panel_scene.instantiate()
	ap_connect_panel.ap_client = ap_client
	add_child(ap_connect_panel)

	var label_scene: PackedScene = load("res://mods-unpacked/CodeTriangle-Archipelago/scenes/ap_overlay.tscn")
	ap_overlay = label_scene.instantiate()
	add_child(ap_overlay)

	ModLoaderLog.info("Ready!", LOG_NAME)
