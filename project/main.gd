extends Control

const CONFIG_PATH := "res://team_record.cfg"

@onready var _teams : Array[Team] = [
	%RedTeam1,
	%RedTeam2,
	%BlueTeam1,
	%BlueTeam2
]
@onready var _red_team_score_field : LineEdit = %RedTeamScore
@onready var _blue_team_score_field : LineEdit = %BlueTeamScore


func _on_save_button_pressed()->void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	
	for team in _teams:
		if team.team_id != "":
			_save_team(team, config)
		team.clear()
	
	_red_team_score_field.text = ""
	_blue_team_score_field.text = ""
	
	config.save(CONFIG_PATH)


func _save_team(team:Team, config:ConfigFile)->void:
	var team_id : String = team.team_id
	# save scores
	var team_scores : Array = config.get_value(team_id, "scores", [])
	if team.name.begins_with("Red"):
		team_scores.append(int(_red_team_score_field.text))
	else:
		team_scores.append(int(_blue_team_score_field.text))
	config.set_value(team_id, "scores", team_scores)
	# save auton
	var auton_tasks : Dictionary = config.get_value(team_id, "auton", {
		Team.AutonTasks.RINGS_SCORED:"0",
		Team.AutonTasks.TOUCH_BAR:false,
		Team.AutonTasks.CROSSED_LINE:false
	})
	var current_team_auton := team.get_auton()
	for task in current_team_auton:
		auton_tasks[task] = current_team_auton[task]
	config.set_value(team_id, "auton", auton_tasks)
	# save drivercontrol
	var driver_tasks : Dictionary = config.get_value(team_id, "drivercontrol", {
		Team.DriverControl.RINGS_SCORED : "0",
		Team.DriverControl.CLIMB_LEVEL : "0",
		Team.DriverControl.WALL_STAKE : false,
		Team.DriverControl.HIGH_STAKE : false,
		Team.DriverControl.GOAL_CLAMP : false,
	})
	var current_team_drivercontrol := team.get_drivercontrol()
	for task in current_team_drivercontrol:
		driver_tasks[task] = current_team_drivercontrol[task]
	config.set_value(team_id, "drivercontrol", driver_tasks)
	# save notes
	var current_notes : Array = config.get_value(team_id, "notes", [])
	var new_notes := team.get_notes()
	new_notes.append_array(current_notes)
	config.set_value(team_id, "notes", _remove_duplicates(new_notes))


func _remove_duplicates(from:Array)->Array:
	var clean_array := []
	for i in from:
		if not clean_array.has(i):
			clean_array.append(i)
	return clean_array
