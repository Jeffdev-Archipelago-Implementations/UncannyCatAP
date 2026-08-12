extends Resource

class_name PthruData



## Not a const so the AP mod can redirect runs to a different folder
static var PTHRUS_DIR: = "user://pthrus/"



var pthru_id: int = int(Time.get_unix_time_from_system())

var pthru_name: String


var player_name: String

var modifiers: Modifiers

var total_prisms: int = 0
var total_score: int = 0
var total_time: float = 0.0
var total_resets: int = 0

var total_clicks: = 0

var furthest_world_ID: int = 0
var furthest_level_ID: int = 0

var can_swim: = false


var level_datas: Dictionary[int, WorldData] = {}
var bonus_level_datas: Dictionary[int, WorldData] = {}


var editor: = false

func modifier_check():
	if modifiers.mods == null:
		for i in modifiers.mods:
			i = false
	else:
		var mod_check: = Modifiers.new()
		for i in mod_check.mods:
			if !modifiers.mods.has(i):
				modifiers.mods[i] = false

func check_total_score() -> bool:
	var check_score: int = 0
	var check_rank: int = 0
	var ok: bool = true
	for world: WorldData in level_datas.values():
		for level: PthruLevelData in world.levels.values():
			check_score += level.best_score
			check_rank += level.rank
	if check_score != total_score:
		push_error("Total score check failed!")
		total_score = check_score
		ok = false
	if check_rank != total_prisms:
		push_error("Total rank check failed!")
		total_prisms = check_rank
		ok = false
	assert (ok, "Check failed!")
	return ok


func levels_beaten() -> int:
	var total: = 0
	for w in Master.game_data.worlds.size():
		if w < furthest_world_ID:
			total += Master.game_data.worlds[w].total_levels()
		else:
			total += furthest_level_ID
			break
	return total


func get_level(world: int, level: int) -> PthruLevelData:
	var world_data = level_datas.get_or_add(world, WorldData.new()) as WorldData
	return world_data.get_level(level)


func set_level(world: int, level: int, data: PthruLevelData) -> void :
	var world_data = level_datas.get_or_add(world, WorldData.new()) as WorldData
	world_data.set_level(level, data)


func get_file_path() -> String:
	return PTHRUS_DIR.path_join("%010x-%s.json" %\
	[pthru_id, pthru_name.validate_filename().to_lower().replace(" ", "_")]
	)


func to_dict() -> Dictionary:
	var flattened_level_datas = {}
	for w in level_datas:
		flattened_level_datas[w] = level_datas[w].to_dict()

	return {
		"pthru_id": pthru_id, 
		"pthru_name": pthru_name, 
		"player_name": player_name, 

		"modifiers": modifiers.mods, 

		"total_prisms": total_prisms, 
		"total_score": total_score, 
		"total_time": total_time, 
		"total_resets": total_resets, 
		"total_clicks": total_clicks, 

		"furthest_level_ID": furthest_level_ID, 
		"furthest_world_ID": furthest_world_ID, 

		"can_swim": can_swim, 

		"level_datas": flattened_level_datas, 
	}


static func from_dict(dict: Dictionary) -> PthruData:
	var new = PthruData.new()

	new.pthru_id = dict.get("pthru_id", new.pthru_id)
	new.pthru_name = dict.get("pthru_name", "")
	new.player_name = dict.get("player_name", "")

	new.modifiers = Modifiers.new()
	new.modifiers.mods = dict.get("modifiers", new.modifiers.mods)

	new.total_prisms = dict.get("total_prisms", new.total_prisms)
	new.total_score = dict.get("total_score", new.total_score)
	new.total_time = dict.get("total_time", new.total_time)
	new.total_resets = dict.get("total_resets", new.total_resets)
	new.total_clicks = dict.get("total_clicks", new.total_clicks)

	new.furthest_level_ID = dict.get("furthest_level_ID", new.furthest_level_ID)
	new.furthest_world_ID = dict.get("furthest_world_ID", new.furthest_world_ID)

	new.can_swim = dict.get("can_swim", new.can_swim)

	var flattened_level_datas = dict.get("level_datas", {})
	for w in flattened_level_datas:
		new.level_datas[int(w)] = WorldData.from_dict(flattened_level_datas[w])

	return new


func save_to_file() -> void :
	if editor:
		return
	DirAccess.make_dir_recursive_absolute(PTHRUS_DIR)
	var path = get_file_path()

	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(path, path + ".bak")

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open pthru file: %s\n Error: %d" % [path, FileAccess.get_open_error()])
		return

	var dict = to_dict()
	var json = JSON.stringify(dict)
	file.store_string(json)
	file.close()


static func load_from_file(path: String) -> PthruData:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to read pthru file: %s\n Error: %d" % [path, FileAccess.get_open_error()])
		return null

	var json = file.get_as_text()
	file.close()
	var dict = JSON.parse_string(json)
	if dict is not Dictionary:
		push_error("Failed to parse pthru file: %s" % path)
		return null

	var new_pthru: = from_dict(dict)

	if path != new_pthru.get_file_path():
		new_pthru.save_to_file()
		DirAccess.remove_absolute(path)
	return new_pthru


class WorldData:
	var levels: Dictionary[int, PthruLevelData] = {}

	func to_dict() -> Dictionary:
		var dict = {}
		for l in levels:
			dict[l] = levels[l].to_dict()
		return dict

	static func from_dict(dict: Dictionary) -> WorldData:
		var new = WorldData.new()

		for l in dict:
			if l is not float and l is not int and l is not String:
				continue
			new.levels[int(l)] = PthruLevelData.from_dict(dict[l])

		return new

	func get_level(level: int) -> PthruLevelData:
		return levels.get_or_add(level, PthruLevelData.new())

	func set_level(level: int, data: PthruLevelData) -> void :
		levels.set(level, data)

func reset_pthru():
	total_prisms = 0
	total_score = 0
	total_time = 0.0
	total_resets = 0
	total_clicks = 0
	furthest_world_ID = 0
	furthest_level_ID = 0
	can_swim = false
	level_datas.clear()
