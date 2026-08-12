class_name ThemeManager extends MarginContainer

signal update_theme(new_theme: Theme)

@export var themes: Array[ThemeBox]
@export var default_theme: ThemeBox

func _ready():
	for themebox in themes:
		themebox.set_theme.connect(set_console_theme)
		themebox.set_pressed_no_signal(themebox.target_theme_path == AP.inst.config.window_theme_path)
	if AP.inst.config.window_theme_path.is_empty():
		default_theme.set_pressed(true)
	else:
		refresh_console_theme()

func set_console_theme(path: String) -> void:
	if path.is_empty(): return
	var theme_res := load(path) as Theme
	if not theme_res: return
	get_window().theme = theme_res
	AP.inst.config.window_theme_path = path
	update_theme.emit(theme_res)

func refresh_console_theme() -> void:
	set_console_theme(AP.inst.config.window_theme_path)
