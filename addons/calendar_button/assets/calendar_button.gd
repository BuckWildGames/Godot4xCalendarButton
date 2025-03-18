extends Button

const CALENDAR: PackedScene = preload("res://addons/calendar_button/assets/calendar.tscn")
enum DIRECTIONS {TOP, BOTTOM, LEFT, RIGHT}

@export_category("Calendar")
@export_group("Options")
@export var include_time: bool = false
@export var use_letter_days: bool = false
@export var use_12_hour_clock: bool = false
@export_group("Anchor and Offsets")
@export var anchor_and_offset: LayoutPreset = PRESET_CENTER
@export var custom_offset: Vector2 = Vector2.ZERO
@export_group("Theme")
@export var custom_theme: Theme = null
@export var custom_font: Font = null
@export var custom_font_size: int = 0
@export_group("Connections")
@export var custom_parent: Control = null

signal calendar_confirmed(date: Dictionary, time: Dictionary)
# (date: {year, month, day}, time: {hour, min})

var calendar: Control = null

func _ready() -> void:
	_create_calendar()

func _pressed() -> void:
	if calendar:
		if calendar.is_visible():
			calendar.set_visible(false)
		else:
			calendar.setup_calendar(include_time, use_letter_days, use_12_hour_clock)
			calendar.set_visible(true)


func _create_calendar() -> void:
	calendar = CALENDAR.instantiate()
	calendar.set_visible(false)
	if custom_parent != null:
		custom_parent.add_child.call_deferred(calendar)
	else:
		add_child(calendar)
	calendar.set_custom_theme(custom_theme, custom_font, custom_font_size)
	calendar.set_anchors_and_offsets_preset(anchor_and_offset)
	if custom_offset != Vector2.ZERO:
		calendar.set_position(Vector2(calendar.get_position().x + custom_offset.x, calendar.get_position().y + custom_offset.y))
	calendar.confirmed.connect(_on_calendar_confirmed)


func _on_calendar_confirmed(date: Dictionary, time: Dictionary) -> void:
	calendar_confirmed.emit(date, time)
