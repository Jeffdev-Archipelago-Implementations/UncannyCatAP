extends Node


const MODS_DIR: = "user://mods/"
const CONFIG_PATH: = "user://mods.json"



var activated: = false

var crashed: = false


var mods: Dictionary[String, Mod] = {}

var enabled: Array[String]


var conflicted: Dictionary[String, Array] = {}


func _init() -> void :
	_load_config()
	_populate_mods()
	if activated:

		crashed = FileAccess.file_exists("user://crashed")
		if crashed:
			activated = false
		var file = FileAccess.open("user://crashed", FileAccess.WRITE)
		file.close()

		_activate_mods()


func quit_cleanly() -> void :
	if activated:
		if DirAccess.remove_absolute("user://crashed") != OK:
			push_error("Failed to remove crash sentinel file.")


func save_config() -> void :
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if not file:
		push_error(FileAccess.get_open_error())
		return

	var dict = {
		"activated": activated, 
		"enabled": enabled, 
	}

	var json = JSON.stringify(dict, "\t")
	file.store_string(json)
	file.close()


func _load_config() -> void :
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not file:
		push_error(FileAccess.get_open_error())
		return

	var json = file.get_as_text()
	file.close()
	var dict = JSON.parse_string(json)
	if dict is not Dictionary:
		push_error("Failed to parse mod config json.")
		return

	activated = dict.get("activated", false)

	var enabled_arr = dict.get("enabled", [])
	if enabled_arr is not Array:
		return

	for id in enabled_arr:
		if id is String:
			enabled.append(id)


func _populate_mods() -> void :
	if OS.is_debug_build():
		if FileAccess.file_exists("res://mod.json"):
			var file = FileAccess.open("res://mod.json", FileAccess.READ)
			if not file:
				push_error(FileAccess.get_open_error())
			var json = file.get_as_text()
			var mod = Mod.from_json(json)
			mod.path = "DEBUG"
			mods[mod.id] = mod

	if not DirAccess.dir_exists_absolute(MODS_DIR):
		return

	var reader = ZIPReader.new()
	for file in DirAccess.get_files_at(MODS_DIR):
		if not file.ends_with(".zip"):
			continue

		var path = MODS_DIR.path_join(file)
		var err = reader.open(path)
		if err != OK:
			push_error("Failed to open mod file %s" % file)
			continue

		if not reader.file_exists("mod.json"):
			push_error("Mod %s contains no mod.json" % file)
			continue

		var json = reader.read_file("mod.json").get_string_from_utf8()
		var mod = Mod.from_json(json)
		mod.path = path

		if mods.has(mod.id):
			push_error("Mod ID conflict between %s and %s" % [mods[mod.id].path.get_file(), mod.path.get_file()])
			if not conflicted.has(mod.id):
				conflicted[mod.id] = [mods[mod.id]]
			conflicted[mod.id].append(mod)

		mods[mod.id] = mod


func _activate_mods() -> void :
	for id in enabled:
		if not mods.has(id):
			push_error("Enabled mod id %s does not exist." % id)
			continue
		var mod = mods[id]
		if mod.path != "DEBUG":
			if not ProjectSettings.load_resource_pack(mod.path):
				push_error("Failed to load resources for mod %s" % mod.path.get_file())
				continue

		if not mod.mod_script.is_empty():
			var ModScript = ResourceLoader.load(mod.mod_script, "GDScript", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
			if not ModScript:
				push_error("Failed to load mod script for %s" % mod.path.get_file())
				continue

			var instance = ModScript.new() as Node
			if not instance:
				push_error("Mod script for %s does not extend Node." % mod.path.get_file())
				continue

			instance.name = mod.id
			add_child(instance)


class Mod:
	var id: String = "[unset]"
	var version: String = "[unset]"
	var name: String = "[unset]"
	var author: String = "[unset]"
	var description: String = "[unset]"

	var path: String = ""
	var mod_script: String = ""

	static func from_json(json: String) -> Mod:
		var dict = JSON.parse_string(json)
		if dict is Dictionary:
			return from_dict(dict)
		else:
			return null

	static func from_dict(dict: Dictionary) -> Mod:
		var new = Mod.new()

		new.id = dict.get("id", new.id)
		new.version = dict.get("version", new.version)
		new.name = dict.get("name", new.name)
		new.author = dict.get("author", new.author)
		new.description = dict.get("description", new.description)
		new.mod_script = dict.get("mod_script", new.mod_script)

		return new
