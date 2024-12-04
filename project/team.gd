class_name Team
extends VBoxContainer

enum AutonTasks {RINGS_SCORED, CROSSED_LINE, TOUCH_BAR}
enum DriverControl {RINGS_SCORED, CLIMB_LEVEL, WALL_STAKE, HIGH_STAKE, GOAL_CLAMP}

var team_id : String : get = get_team_id
var _next_note_field : LineEdit : set = _set_next_note_field

@onready var _auton_tasks := {
	AutonTasks.RINGS_SCORED : $Auton/RingsScored,
	AutonTasks.CROSSED_LINE : $Auton/CrossedLine,
	AutonTasks.TOUCH_BAR : $Auton/Bar
}
@onready var _driver_control := {
	DriverControl.RINGS_SCORED : $DriverControl/TotalRingsScored,
	DriverControl.CLIMB_LEVEL : $DriverControl/ClimbLevel,
	DriverControl.WALL_STAKE : $DriverControl2/WallStake,
	DriverControl.HIGH_STAKE : $DriverControl2/HighStake,
	DriverControl.GOAL_CLAMP : $DriverControl2/GoalClamp,
}
@onready var _team_id_line_edit : LineEdit = $TeamID
@onready var _note_container : VBoxContainer = $Notes


func _ready()->void:
	_set_next_note_field($Notes/NoteField)


func get_team_id()->String:
	return _team_id_line_edit.text


func get_notes()->Array[String]:
	var notes : Array[String] = []
	for note_field : LineEdit in _note_container.get_children():
		if note_field.text != "":
			notes.append(note_field.text)
	return notes


func _reset_tasks(task_dict: Dictionary) -> void:
	for entry_point in task_dict.values():
		if entry_point is CheckBox:
			entry_point.button_pressed = false
		elif entry_point is LineEdit:
			entry_point.text = ""


func _eval_dictionary(dict: Dictionary) -> Dictionary:
	var processed_dict := {}
	for key in dict:
		var value = dict[key]
		if value is CheckBox:
			processed_dict[key] = value.button_pressed
		elif value is LineEdit:
			processed_dict[key] = value.text
	return processed_dict


func get_auton()->Dictionary:
	return _eval_dictionary(_auton_tasks)


func get_drivercontrol() -> Dictionary:
	return _eval_dictionary(_driver_control)


func clear()->void:
	_team_id_line_edit.text = ""
	for note_field :LineEdit in _note_container.get_children():
		note_field.queue_free()
	_reset_tasks(_auton_tasks)
	_reset_tasks(_driver_control)
	_add_new_note_field()


func _set_next_note_field(value:LineEdit)->void:
	if _next_note_field:
		if _next_note_field.text_changed.is_connected(_on_next_note_field_text_changed):
			_next_note_field.text_changed.disconnect(_on_next_note_field_text_changed)
	_next_note_field = value
	_next_note_field.text_changed.connect(_on_next_note_field_text_changed)


func _add_new_note_field()->void:
	var note_field := LineEdit.new()
	note_field.placeholder_text = "Notes"
	_note_container.add_child(note_field)
	_set_next_note_field(note_field)


func _on_next_note_field_text_changed(new_text:String)->void:
	if new_text != "":
		_add_new_note_field()
