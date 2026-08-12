class_name GodotAPMain extends ColorRect
## Directly opens the CommonClient Console in the current SceneTree
## Used for standalone client applications

func _ready():
	if OS.is_debug_build():
		AP.inst.cmd_manager.debug_hidden = false

	AP.inst.AP_CLIENT_VERSION = Version.val(0,1,0) # GodotAP CommonClient version
	AP.log(AP.inst.AP_CLIENT_VERSION)
	AP.inst.set_tags(["TextOnly"])
	AP.inst.AP_ITEM_HANDLING = AP.inst.ItemHandling.ALL
	AP.inst.creds.updated.connect(GodotAPMain.save_connection)
	GodotAPMain.load_connection()

	if AP.inst.output_console:
		AP.inst.close_console()
	get_window().min_size = Vector2(350,400)
	get_window().title = "AP Text Client"
	AP.inst.load_packed_console_as_scene(get_tree(), load("res://godot_ap/ui/common_client.tscn"))

static func load_connection():
	var conn_info_file: FileAccess = FileAccess.open("user://ap/connection.dat", FileAccess.READ)
	if not conn_info_file: return
	var ip = conn_info_file.get_line()
	var port = conn_info_file.get_line()
	var slot = conn_info_file.get_line()
	AP.inst.creds.update(ip, port, slot, "")
	conn_info_file.close()
static func save_connection(creds: APCredentials):
	DirAccess.make_dir_recursive_absolute("user://ap/")
	var conn_info_file: FileAccess = FileAccess.open("user://ap/connection.dat", FileAccess.WRITE)
	if not conn_info_file: return
	conn_info_file.store_line(creds.ip)
	conn_info_file.store_line(creds.port)
	conn_info_file.store_line(creds.slot)
	conn_info_file.close()
