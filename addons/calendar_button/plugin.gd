@tool
extends EditorPlugin

# Called when the plugin is enabled
func _enter_tree() -> void:
	add_custom_type("CalendarButton", "Button", preload("res://addons/calendar_button/assets/calendar_button.gd"), preload("res://addons/calendar_button/assets/icon_green.svg"))


# Called when the plugin is disabled
func _exit_tree() -> void:
	remove_custom_type("CalendarButton")
