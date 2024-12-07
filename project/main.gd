extends Control

const CONFIG_PATH := "res://team_record.cfg"

@onready var _teams : Array[Node] = $ScrollContainer/VBoxContainer/Teams.get_children()
@onready var _on_load_panel : PanelContainer = $Panel
@onready var _team_lookup_section : HBoxContainer = $ScrollContainer/VBoxContainer/TeamLookups


func _on_save_button_pressed()->void:
	for team: Team in _teams:
		if team.team_id != "":
			if multiplayer.has_multiplayer_peer():
				save_team.rpc_id(
					1, team.team_id, team.get_auton(),
					team.get_drivercontrol(), team.get_notes()
				)
			else:
				save_team(team.team_id, team.get_auton(), team.get_drivercontrol(), team.get_notes())
		team.clear()


@rpc("any_peer", "reliable")
func save_team(team_id: String, auton: Dictionary, drivercontrol: Dictionary, notes: Array[String]) -> void:
	if not multiplayer.is_server():
		return
	
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	
	# save scores
	var team_scores : Array = config.get_value(team_id, "scores", [])
	config.set_value(team_id, "scores", team_scores)
	# save auton
	var auton_tasks : Dictionary = config.get_value(team_id, "auton", {
		Team.AutonTasks.RINGS_SCORED:"0",
		Team.AutonTasks.TOUCH_BAR:false,
		Team.AutonTasks.CROSSED_LINE:false
	})
	for task in auton:
		auton_tasks[task] = auton[task]
	config.set_value(team_id, "auton", auton_tasks)
	# save drivercontrol
	var driver_tasks : Dictionary = config.get_value(team_id, "drivercontrol", {
		Team.DriverControl.RINGS_SCORED : "0",
		Team.DriverControl.CLIMB_LEVEL : "0",
		Team.DriverControl.WALL_STAKE : false,
		Team.DriverControl.HIGH_STAKE : false,
		Team.DriverControl.GOAL_CLAMP : false,
	})
	for task in drivercontrol:
		driver_tasks[task] = drivercontrol[task]
	config.set_value(team_id, "drivercontrol", driver_tasks)
	# save notes
	var current_notes : Array = config.get_value(team_id, "notes", [])
	notes.append_array(current_notes)
	config.set_value(team_id, "notes", _remove_duplicates(notes))
	
	config.save(CONFIG_PATH)


func _remove_duplicates(from:Array)->Array:
	var clean_array := []
	for i in from:
		if not clean_array.has(i):
			clean_array.append(i)
	return clean_array


func _on_server_button_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(7000)
	multiplayer.multiplayer_peer = peer
	_on_load_panel.hide()


func _on_client_button_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 7000)
	multiplayer.multiplayer_peer = peer
	_on_load_panel.hide()
	_team_lookup_section.hide()


func _on_local_button_pressed() -> void:
	_on_load_panel.hide()


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		var num := new_text.to_int()
		if num >= 1 and num <= 4:
			for x in 4 - num:
				_teams[x].hide()
			for x in num:
				_teams[3 - x].show()
			if num == 1:
				$ScrollContainer/VBoxContainer/Teams.columns = 1
			else:
				$ScrollContainer/VBoxContainer/Teams.columns = 2
