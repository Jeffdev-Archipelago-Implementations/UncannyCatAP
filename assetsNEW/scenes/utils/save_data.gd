extends Resource
class_name SaveData

## This is not a const anymore, so that the AP mod can swap in it's own save when connecting.
static var SAVE_PATH: = "user://save_data.ini"
const VANILLA_SAVE_PATH: = "user://save_data.ini"
const HIDDEN_UNLOCK_PREFIXES: Array[StringName] = [&"songs_"]

static func is_ap_save() -> bool:
	return SAVE_PATH != VANILLA_SAVE_PATH


var play_points: int

var current_costume: StringName = &"canny":
	set(value):
		current_costume = value
		Master.current.update_costume()

var current_pskin: int = 0

var current_gskin: int = 1

var WORLDS_PROGRESS: int = -1
var QUEST_PROGRESS: int = 0

var ap_item_index: int = 0

## Deaths banked towards the next DeathLink send, per the AP mod's amnesty setting.
var ap_deathlink_amnesty: int = 0

var quest_keys: Dictionary[StringName, bool] = {
	&"questkey_0": false, 
	&"questkey_1": false, 
	&"questkey_2": false, 
	&"questkey_3": false, 
	&"questkey_4": false, 
	&"questkey_5": false, 
	&"questkey_P": false, 
	&"questkey_E": false, 
}


var seen_cutscenes: Array[StringName] = []

var art_slot: int = 0
var art1_costume: StringName = &"canny"
var art2_costume: StringName = &"uncanny"
var art3_costume: StringName = &"_blank"


var pthrus: Array[PthruData]

var pending_unlocks: Array[StringName] = []

var unlocks: Dictionary[StringName, bool] = {
	&"game_peak_hunter": false, 

	&"mode_endless": false, 
	&"mode_editor": false, 

	&"mod_easy_mode": false, 
	&"mod_hard_mode": false, 
	&"mod_burst": false, 
	&"mod_telekinesis": false, 
	&"mod_buddy": false, 
	&"mod_parry": false, 
	&"mod_jumpy": false, 
	&"mod_dizzy": false, 
	&"mod_missiles": false, 
	&"mod_sticky": false, 
	&"mod_god": false, 

	&"extra_catartist": false, 
	&"minigame_bartbash": false, 
	&"minigame_meowl": false, 
	&"minigame_uncannydash": false, 

	&"extra_costumes": false, 
	&"extra_mystery_phone": false, 
	&"extra_sound_test": false, 

	&"costume__blank": true, 
	&"costume_canny": true, 
	&"costume_uncanny": true, 
	&"costume_ms_canny": false, 
	&"costume_retro": false, 
	&"costume_dog": false, 
	&"costume_veteran": false, 
	&"costume_cannydigo": false, 
	&"costume_rainbow": false, 
	&"costume_king": false, 
	&"costume_catfish": false, 
	&"costume_builder": false, 
	&"costume_nothing": false, 
	&"costume_copycat": false, 

	&"costume_arleling": false, 
	&"costume_bingus": false, 
	&"costume_minnie": false, 
	&"costume_rudy": false, 
	&"costume_chen": false, 
	&"costume_pig": false, 
	&"costume_ploobie": false, 
	&"costume_robert": false, 
	&"costume_swag": false, 
	&"costume_true": false, 
	&"costume_wires": false, 

	&"songs_fields": false, 
	&"songs_cosmic": false, 
}

var ap_mod_qty: Dictionary[StringName, int] = {
	&"mod_burst_qty": 0, 
	&"mod_telekinesis_qty": 0, 
	&"mod_buddy_qty": 0, 
	&"mod_parry_qty": 0, 
	&"mod_jumpy_qty": 0, 
	&"mod_dizzy_qty": 0, 
	&"mod_missiles_qty": 0, 
	&"mod_sticky_qty": 0,
}

var endless_last_used_name: String = ""

var endless_scores: Array[EndlessScore] = []

static var _lock: = _Lock.new()

func pthru_check():

	for i in pthrus:
		if i.total_clicks == null:
			i.total_clicks = 0

func write_save() -> void :
	_lock.lock()
	_write_save_unsafe()
	_lock.unlock()

func _write_save_unsafe() -> void :
	if PThru.test_mode:
		return
	var conf: = ConfigFile.new()

	conf.set_value("UCG", "play_points", play_points)
	conf.set_value("UCG", "current_costume", current_costume)
	conf.set_value("UCG", "current_pskin", current_pskin)
	conf.set_value("UCG", "current_gskin", current_gskin)
	conf.set_value("UCG", "WORLDS_PROGRESS", WORLDS_PROGRESS)
	conf.set_value("UCG", "QUEST_PROGRESS", QUEST_PROGRESS)
	if is_ap_save():
		conf.set_value("UCG", "ap_item_index", ap_item_index)
		conf.set_value("UCG", "ap_deathlink_amnesty", ap_deathlink_amnesty)
	for q in quest_keys:
		conf.set_value("UCG", String(q), quest_keys[q])
	conf.set_value("UCG", "seen_cutscenes", seen_cutscenes)

	conf.set_value("ART", "art_slot", art_slot)
	conf.set_value("ART", "art1_costume", art1_costume)
	conf.set_value("ART", "art2_costume", art2_costume)
	conf.set_value("ART", "art3_costume", art3_costume)

	conf.set_value("UNLOCKS", "pending_unlocks", pending_unlocks)
	for u in unlocks:
		conf.set_value("UNLOCKS", String(u), unlocks[u])

	if is_ap_save():
		for a in ap_mod_qty:
			conf.set_value("AP_MODIFIER_QUANTITY", String(a), ap_mod_qty[a])

	conf.set_value("ENDLESS", "last_used_name", endless_last_used_name)

	endless_scores.sort_custom( func(a, b): return a.score > b.score)
	for i in mini(endless_scores.size(), 10):
		conf.set_value("ENDLESS", str(i) + "name", endless_scores[i].name)
		conf.set_value("ENDLESS", str(i) + "score", endless_scores[i].score)
		conf.set_value("ENDLESS", str(i) + "cleared", endless_scores[i].cleared)

	if Master.game_data.current_pthru:
		Master.game_data.current_pthru.save_to_file()


	var save: = conf.save(SAVE_PATH)

	if save != OK:
		printerr("Save failed.")

func load_save() -> bool:
	_lock.lock()
	var result: = _load_save_unsafe()
	_lock.unlock()
	return result

func _load_save_unsafe() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var conf: = ConfigFile.new()

		var load: = conf.load(SAVE_PATH)

		if load != OK:
			printerr("Load failed.")
			return false

		play_points = conf.get_value("UCG", "play_points", 0)
		current_costume = conf.get_value("UCG", "current_costume", current_costume)
		current_pskin = conf.get_value("UCG", "current_pskin", 0)
		current_gskin = conf.get_value("UCG", "current_gskin", 0)
		WORLDS_PROGRESS = conf.get_value("UCG", "WORLDS_PROGRESS", 0)
		QUEST_PROGRESS = conf.get_value("UCG", "QUEST_PROGRESS", 0)
		ap_item_index = conf.get_value("UCG", "ap_item_index", 0) if is_ap_save() else 0
		ap_deathlink_amnesty = conf.get_value("UCG", "ap_deathlink_amnesty", 0) if is_ap_save() else 0
		for q in quest_keys:
			quest_keys[q] = conf.get_value("UCG", String(q), quest_keys[q])
		seen_cutscenes = Array(
			conf.get_value("UCG", "seen_cutscenes", []), 
			TYPE_STRING_NAME, &"", null
		)

		art_slot = conf.get_value("ART", "art_slot", art_slot)
		art1_costume = conf.get_value("ART", "art1_costume", art1_costume)
		art2_costume = conf.get_value("ART", "art2_costume", art2_costume)
		art3_costume = conf.get_value("ART", "art3_costume", art3_costume)
		Utils.update_copycat()

		pending_unlocks = Array(
			conf.get_value("UNLOCKS", "pending_unlocks", []), 
			TYPE_STRING_NAME, &"", null
		)
		for u in unlocks:
			unlocks[u] = conf.get_value("UNLOCKS", String(u), unlocks[u])
		unlocks[&"costume__blank"] = true

		if is_ap_save():
			for a in ap_mod_qty:
				ap_mod_qty[a] = conf.get_value("AP_MODIFIER_QUANTITY", String(a), ap_mod_qty[a])

		endless_last_used_name = conf.get_value("ENDLESS", "last_used_name", "")
		for i in 10:
			if not conf.has_section_key("ENDLESS", str(i) + "name"):
				break
			var entry = EndlessScore.new()
			entry.name = conf.get_value("ENDLESS", str(i) + "name", "")
			entry.score = conf.get_value("ENDLESS", str(i) + "score", 0)
			entry.cleared = conf.get_value("ENDLESS", str(i) + "cleared", 0)
			var dupe: = false
			for s in endless_scores:
				if s.name == entry.name and s.score == entry.score and s.cleared == entry.cleared:
					dupe = true
					break
			if not dupe:
				endless_scores.append(entry)

		pthrus = []
		DirAccess.make_dir_recursive_absolute(PthruData.PTHRUS_DIR)
		var files = DirAccess.get_files_at(PthruData.PTHRUS_DIR)
		files.reverse()
		for file in files:
			if not file.ends_with(".json"):
				continue

			var path = PthruData.PTHRUS_DIR.path_join(file)
			var data = PthruData.load_from_file(path)
			if data:
				pthrus.append(data)

		pthru_check()
		for i in pthrus:
			i.modifier_check()
		return true
	return false


class _Lock:
	signal unlocked()

	var locked: bool = false

	func lock() -> void :
		while locked:
			await unlocked
		locked = true

	func unlock() -> void :
		locked = false
		unlocked.emit()
