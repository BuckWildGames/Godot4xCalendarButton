extends SpinBox

func _ready() -> void:
	_value_changed(get_value())  # Ensure correct formatting on start

func _value_changed(new_value: float) -> void:
	# Ensure numbers below 10 have a leading zero
	var formatted_text = "%02d" % int(new_value)
	get_line_edit().set_text(formatted_text)

func _gui_input(event: InputEvent) -> void:
	# Reapply formatting after any user input
	_value_changed(get_value())
