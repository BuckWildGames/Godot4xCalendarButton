extends Control

const BUTTON_SCENE: PackedScene = preload("res://addons/calendar_button/assets/date_button.tscn")
const WEEKDAYS: Array = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

@onready var panel_container: PanelContainer = $PanelContainer
@onready var grid_dates: GridContainer = $PanelContainer/CalendarContainer/Dates
@onready var label_month_year: Label = $PanelContainer/CalendarContainer/MonthYearContainer/MonthYear
@onready var btn_prev_month: Button = $PanelContainer/CalendarContainer/MonthYearContainer/PrevButton
@onready var btn_next_month: Button = $PanelContainer/CalendarContainer/MonthYearContainer/NextButton
@onready var time: VBoxContainer = $PanelContainer/CalendarContainer/Time
@onready var hour_box: SpinBox = $PanelContainer/CalendarContainer/Time/TimeContainer/HourBox
@onready var min_box: SpinBox = $PanelContainer/CalendarContainer/Time/TimeContainer/MinBox
@onready var am_pm_container: HBoxContainer = $PanelContainer/CalendarContainer/Time/AmPmContainer
@onready var am_pm_button: CheckButton = $PanelContainer/CalendarContainer/Time/AmPmContainer/CheckButton
@onready var ok_button: Button = $PanelContainer/CalendarContainer/OkButton

var year: int = 2025
var month: int = 1
var day: int = 1
var hour: int = 1
var min: int = 0

var days_in_month: int = 0
var first_day_of_week: int = 0

var buttons: Array = []

var include_time: bool = false
var use_letter_days: bool = false
var use_12_hour_clock: bool = false
var is_pm: bool = false

signal confirmed(date: Dictionary, time: Dictionary)

func _ready() -> void:
	_get_current_date()
	btn_prev_month.pressed.connect(_on_prev_month)
	btn_next_month.pressed.connect(_on_next_month)
	hour_box.value_changed.connect(_on_hour_changed)
	min_box.value_changed.connect(_on_min_changed)
	am_pm_button.toggled.connect(_on_am_pm_toggled)
	ok_button.pressed.connect(_on_ok)


func set_custom_theme(new_theme: Theme, new_font: Font, new_font_size: int) -> void:
	if new_theme == null:
		new_theme = Theme.new()
	new_theme.set_default_font(new_font)
	new_theme.set_default_font_size(new_font_size)
	set_theme(new_theme)
	_apply_theme_to_children(self, new_theme)


func setup_calendar(use_time: bool, use_letters: bool, use_12_hour: bool) -> void:
	_get_current_date()
	_clear_calendar()
	_reset_time(use_12_hour)
	_generate_weekdays(use_letters)
	_generate_dates()
	_update_month_label()
	if use_time:
		time.set_visible(true)
	include_time = use_time
	use_letter_days = use_letters
	use_12_hour_clock = use_12_hour


func _clear_calendar() -> void:
	for child in grid_dates.get_children():
		child.queue_free()
	buttons.clear()


func _reset_time(use_12_hour: bool = false) -> void:
	time.set_visible(false)
	hour_box.set_value_no_signal(hour)
	min_box.set_value_no_signal(min)
	if use_12_hour:
		if hour >= 12:
			is_pm = true
		else:
			is_pm = false
		am_pm_button.set_pressed_no_signal(is_pm)
		hour_box.set_value_no_signal(hour - 12)
		hour_box.set_min(1.0)
		hour_box.set_max(12.0)
		am_pm_container.set_visible(true)
	else:
		hour_box.set_min(0.0)
		hour_box.set_max(23.0)
		am_pm_container.set_visible(false)


func _get_current_date() -> void:
	var datetime = Time.get_datetime_dict_from_system()
	var timezone = Time.get_time_zone_from_system()
	var bias = timezone.bias # Offset in minutes from UTC
	var offset_hours = -bias / 60 # Convert minutes to hours
	var offset_minutes = -bias % 60 # Get remaining minutes
	year = datetime.year
	month = datetime.month
	day = datetime.day
	hour = datetime.hour
	min = datetime.minute
	print("UTC Offset: %d:%02d" % [offset_hours, abs(offset_minutes)])


func _generate_weekdays(use_letters: bool = false) -> void:
	for days in WEEKDAYS:
		var label = Label.new()
		if use_letters:
			days = days.substr(0, 1)
		label.set_text(days)
		label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		grid_dates.add_child(label)


func _generate_dates() -> void:
	var date = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_datetime_dict({
		"year": year, "month": month, "day": day
	}))
	days_in_month = _get_days_in_month(month, year)
	first_day_of_week = date.weekday
	# Add empty spaces before the first day to align weekdays
	for _i in range(first_day_of_week):
		var empty_label = Label.new()
		grid_dates.add_child(empty_label)
	# Add date buttons
	for days in range(1, days_in_month + 1):
		var button = BUTTON_SCENE.instantiate() as Button
		button.set_text(str(days))
		button.pressed.connect(_on_date_selected.bind(days, button))
		grid_dates.add_child(button)
		buttons.append(button)
		# Auto-focus the current day
		if days == day and year == Time.get_datetime_dict_from_system().year and month == Time.get_datetime_dict_from_system().month:
			button.grab_focus()


func _get_days_in_month(target_month: int, target_year: int) -> int:
	var next_month = target_month + 1 if target_month < 12 else 1
	var next_year = target_year if target_month < 12 else target_year + 1
	var first_day_next_month = Time.get_unix_time_from_datetime_dict({
		"year": next_year, "month": next_month, "day": 1
	})
	var last_day_of_current_month = Time.get_datetime_dict_from_unix_time(first_day_next_month - 86400)
	return last_day_of_current_month.day


func _on_date_selected(new_day: int, button: Button) -> void:
	day = new_day
	print("Selected date: %d-%02d-%02d" % [year, month, day])
	# Focus the selected button
	button.grab_focus()


func _on_prev_month() -> void:
	month -= 1
	if month < 1:
		month = 12
		year -= 1
	setup_calendar(include_time, use_letter_days, use_12_hour_clock)


func _on_next_month() -> void:
	month += 1
	if month > 12:
		month = 1
		year += 1
	setup_calendar(include_time, use_letter_days, use_12_hour_clock)


func _on_hour_changed(new_hour: float) -> void:
	if is_pm:
		new_hour = new_hour + 12
	hour = int(new_hour)
	print("Hour changed: " + str(new_hour))


func _on_min_changed(new_min: float) -> void:
	min = int(new_min)
	print("Minute changed: " + str(new_min))


func _on_am_pm_toggled(toggled_on: bool) -> void:
	is_pm = toggled_on
	if is_pm:
		hour = hour + 12
	else:
		hour = hour - 12
	hour_box.set_value_no_signal(hour)
	print("Am Pm changed: " + str(hour))


func _on_ok() -> void:
	confirmed.emit({"year": year, "month": month, "day": day}, {"hour": hour, "min": min})
	set_visible(false)
	print("Calendar confirmed")


func _update_month_label() -> void:
	label_month_year.set_text("%s %d" % [_get_month_name(month), year])


func _get_month_name(m: int) -> String:
	var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	return months[m - 1]


func _apply_theme_to_children(node: Node, new_theme: Theme) -> void:
	for child in node.get_children():
		if child is Control:  # Apply theme only to UI elements
			child.set_theme(new_theme)
		_apply_theme_to_children(child, new_theme)  # Recursively apply to all children
