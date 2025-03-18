extends SpinBox

var focused: bool = false

func _ready() -> void:
	_value_changed(get_value())  # Ensure correct formatting on start


func _process(_delta: float) -> void:
	if has_focus() or get_line_edit().has_focus():
		focused = true
	elif focused:
		focused = false
		_value_changed(get_value())



func _value_changed(new_value: float) -> void:
	# Ensure numbers below 10 have a leading zero
	var formatted_text = "%02d" % int(new_value)
	get_line_edit().set_text(formatted_text)



#func _gui_input(_event: InputEvent) -> void:
	# Reapply formatting after any user input
	#_value_changed(get_value())
