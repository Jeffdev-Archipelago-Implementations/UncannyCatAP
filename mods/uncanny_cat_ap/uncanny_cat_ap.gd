extends Node

const AP_CONNECT_PATH = "res://mods/uncanny_cat_ap/ap_connect_screen.tscn"
const AP_AUTOLOAD_PATH = "res://godot_ap/autoloads/archipelago.tscn"
const AP_TITLE_SCREEN = preload("res://mods/uncanny_cat_ap/ap_title_screen.gd")
## Script override for breakable blocks
const AP_BLOCK = preload("res://mods/uncanny_cat_ap/ap_block.gd")
const EASY_MODE_ENDING = preload("res://assetsNEW/scenes/objects/misc/easy_mode_ending.gd")
const AP_SAVES_DIR = "user://ap_saves/"
const VANILLA_SAVE_PATH = "user://save_data.ini"
const VANILLA_PTHRUS_DIR = "user://pthrus/"

const AP_DROP_GRACE = 1.0

const COIN_IDS_PATH = "res://mods/uncanny_cat_ap/coin_ids.json"
var coin_ids: Dictionary = {}

## COOLER MODS CONFIG
const CONFIG_PATH = "user://mod_data/configs/jeffdev.uncannycatap.json"
const CONFIG_DEFAULTS = {
	"death_link": 0,
	"death_link_amnesty": 5,
	"chill_mode": 0,
	"panic_mode": 0,
	"show_ap_msgs": true,
	"ap_msg_queue_time": 3,
}
var cooler_mods_node

# OFFSETS
const BASE_ID = 100

# LOCATION OFFSETS
const PEAK_OFFSET = 1000
const SMILEY_OFFSET = 2000
const GOOD_OFFSET = 3000
const BORT_OFFSET = 5000
const MEOWLS_OFFSET = 6000
const DASH_OFFSET = 7000
const ALL_COIN_OFFSET = 8000

# ITEM OFFSETS
const WORLD_ITEM_OFFSET = 1000
const GIMMICK_ITEM_OFFSET = 2000
const MODIFIER_ITEM_OFFSET = 3000
const VILLA_ITEM_OFFSET = 4000
const COSTUME_ITEM_OFFSET = 5000

## Cannium Prism, only in the pool with the macguffin goal
const MACGUFFIN_ITEM_ID = BASE_ID + 6000

# Uncany Cat Spray modifier infos
const SPRAY_MOD_NAME = "uncanny_cat_spray"
const SPRAY_QTY_KEY = &"mod_uncanny_cat_spray_qty"
const SPRAY_ICON = preload("res://mods/uncanny_cat_ap/resources/uncanny_cat_spray.png")

const GIMMICK_ITEM_IDS: Dictionary[String, int] = {
	"Breakable Tiles": BASE_ID + 2000,
	"Keys": BASE_ID + 2001,
	"Stop Markers": BASE_ID + 2002,
	"Go Markers": BASE_ID + 2003,
	"Jump Pads": BASE_ID + 2004,
	"Switch Tiles": BASE_ID + 2005,
	"Dog": BASE_ID + 2006,
	"Portals": BASE_ID + 2007,
	"Nuke": BASE_ID + 2008,
	# World 5 Exclusive
	"Golf Balls": BASE_ID + 2009,
	"Landmines": BASE_ID + 2010,
	# World P Exclusive
	"Metronome": BASE_ID + 2011,
}

const ITEM_ID_TO_KEYS: Dictionary[int, String] = {
	# GIMMICKS
	BASE_ID + GIMMICK_ITEM_OFFSET:     "ap_tiles",
	BASE_ID + GIMMICK_ITEM_OFFSET + 1: "ap_keys",
	BASE_ID + GIMMICK_ITEM_OFFSET + 2: "ap_stop",
	BASE_ID + GIMMICK_ITEM_OFFSET + 3: "ap_go",
	BASE_ID + GIMMICK_ITEM_OFFSET + 4: "ap_jump",
	BASE_ID + GIMMICK_ITEM_OFFSET + 5: "ap_switch",
	BASE_ID + GIMMICK_ITEM_OFFSET + 6: "ap_dog",
	BASE_ID + GIMMICK_ITEM_OFFSET + 7: "ap_portal",
	BASE_ID + GIMMICK_ITEM_OFFSET + 8: "ap_nuke",
	# World 5 Exclusive
	BASE_ID + GIMMICK_ITEM_OFFSET + 9: "ap_golf",
	BASE_ID + GIMMICK_ITEM_OFFSET + 10: "ap_mine",
	# World P Exclusive
	BASE_ID + GIMMICK_ITEM_OFFSET + 11: "ap_metronome",

	# TRAPS/MODS
	BASE_ID + MODIFIER_ITEM_OFFSET:     "mod_burst",
	BASE_ID + MODIFIER_ITEM_OFFSET + 1: "mod_telekinesis",
	BASE_ID + MODIFIER_ITEM_OFFSET + 2: "mod_buddy",
	BASE_ID + MODIFIER_ITEM_OFFSET + 3: "mod_parry",
	BASE_ID + MODIFIER_ITEM_OFFSET + 4: "mod_jumpy",
	BASE_ID + MODIFIER_ITEM_OFFSET + 5: "mod_dizzy",
	BASE_ID + MODIFIER_ITEM_OFFSET + 6: "mod_missiles",
	BASE_ID + MODIFIER_ITEM_OFFSET + 7: "mod_sticky",
	BASE_ID + VILLA_ITEM_OFFSET:	 	"mod_uncanny_cat_spray", # This is a modded modifier, kinda in its own category

	# VILLA STUFF
	BASE_ID + VILLA_ITEM_OFFSET + 1: "extra_catartist",
	BASE_ID + VILLA_ITEM_OFFSET + 2: "extra_mystery_phone",
	BASE_ID + VILLA_ITEM_OFFSET + 3: "minigame_meowl",
	BASE_ID + VILLA_ITEM_OFFSET + 4: "minigame_uncannydash",
	BASE_ID + VILLA_ITEM_OFFSET + 5: "minigame_bartbash",
	BASE_ID + VILLA_ITEM_OFFSET + 6: "extra_sound_test",

	# COSTUMES
	BASE_ID + COSTUME_ITEM_OFFSET: 	   "costume_copycat",
	BASE_ID + COSTUME_ITEM_OFFSET + 1: "costume_ms_canny",
	BASE_ID + COSTUME_ITEM_OFFSET + 2: "costume_retro",
	BASE_ID + COSTUME_ITEM_OFFSET + 3: "costume_dog",
	BASE_ID + COSTUME_ITEM_OFFSET + 4: "costume_veteran",
	BASE_ID + COSTUME_ITEM_OFFSET + 5: "costume_cannydigo",
	BASE_ID + COSTUME_ITEM_OFFSET + 6: "costume_rainbow",
	BASE_ID + COSTUME_ITEM_OFFSET + 7: "costume_wires",
	BASE_ID + COSTUME_ITEM_OFFSET + 8: "costume_bingus",
	BASE_ID + COSTUME_ITEM_OFFSET + 9: "costume_minnie",
	BASE_ID + COSTUME_ITEM_OFFSET + 10: "costume_robert",
	BASE_ID + COSTUME_ITEM_OFFSET + 11: "costume_rudy",
	BASE_ID + COSTUME_ITEM_OFFSET + 12: "costume_ploobie",
	BASE_ID + COSTUME_ITEM_OFFSET + 13: "costume_pig",
	BASE_ID + COSTUME_ITEM_OFFSET + 14: "costume_chen",
	BASE_ID + COSTUME_ITEM_OFFSET + 15: "costume_swag",
	BASE_ID + COSTUME_ITEM_OFFSET + 16: "costume_arleling",
	BASE_ID + COSTUME_ITEM_OFFSET + 17: "costume_true",
	BASE_ID + COSTUME_ITEM_OFFSET + 18: "costume_king",
	BASE_ID + COSTUME_ITEM_OFFSET + 19: "costume_catfish",
	BASE_ID + COSTUME_ITEM_OFFSET + 20: "costume_builder",
	BASE_ID + COSTUME_ITEM_OFFSET + 21: "costume_nothing",
}

# This is to handle spritesheets for animating gifts
const GIMMICK_ICON_SPECS: Dictionary[StringName, Array] = {
	&"ap_tiles":     ["res://assetsNEW/graphics/gimmicks/dblock.png", 32, 32, 1],
	&"ap_keys":      ["res://assetsNEW/graphics/collectibles/key.png", 72, 72, 72],
	&"ap_stop":      ["res://assetsNEW/graphics/collectibles/stop_token.png", 72, 72, 1],
	&"ap_go":        ["res://assetsNEW/graphics/collectibles/speed_token.png", 72, 72, 1],
	&"ap_jump":      ["res://mods/uncanny_cat_ap/resources/jump_pad.png", 128, 128, 1],
	&"ap_switch":    ["res://mods/uncanny_cat_ap/resources/switch_tiles.png", 608, 302, 1],
	&"ap_dog":       ["res://assetsNEW/graphics/player/costume_dog.png", 512, 512, 1],
	&"ap_portal":    ["res://assetsNEW/graphics/gimmicks/portal_new.png", 128, 128, 1],
	&"ap_nuke":      ["res://assetsNEW/graphics/collectibles/nuke.png", 50, 50, 11],
	&"ap_golf":      ["res://assetsNEW/graphics/stage/deco/W1/golfball.png", 360, 360, 1],
	&"ap_mine":      ["res://assetsNEW/graphics/gimmicks/landmine.png", 48, 48, 1],
	&"ap_metronome": ["res://assetsNEW/graphics/gimmicks/metronome.png", 229, 329, 1],
}

## Seconds per frame for the animated icons.
const ICON_FRAME_TIME = 0.08

const GIMMICK_ROW_ORIGIN = Vector2(35, 200)
const GIMMICK_CELL = 28.0
const GIMMICK_PADDING = 8.0
const GIMMICK_PER_ROW = 6
const GIMMICK_LOCKED_TINT = Color(0.25, 0.25, 0.25, 0.65)

## Goal color tint
const GOAL_TINT = Color(0.4, 1.0, 0.4)

const HUD_FONT = preload("res://assetsNEW/fonts/Arial Rounded MT Bold Regular.ttf")
const AMNESTY_LABEL_NAME = &"APDeathlinkAmnesty"
const AMNESTY_LABEL_RECT = Rect2(132, 163, 127, 20)
const AMNESTY_LABEL_COLOR = Color(1, 0.35, 0.458334)
var amnesty_labels: Array[Label] = []
var _spray_icon: TextureRect
var _vanilla_prism_unlocks: Dictionary[StringName, int] = {}
var prism_labels: Array[Label] = []

## The 'goal_level' slot option, as [world, 1-based level] per choice.
const GOAL_LEVELS: Array[Vector2i] = [
	Vector2i(3, 18),
	Vector2i(4, 17),
	Vector2i(4, 18),
	Vector2i(5, 18),
	Vector2i(6, 17),
]

var config: Dictionary = CONFIG_DEFAULTS.duplicate()

## Row sprites by unlock key
var gimmick_row: Dictionary[StringName, AnimatedSprite2D] = {}

var gimmick_icons: Dictionary[StringName, Texture2D] = {}

var _animated_icons: Array[Array] = []
var _icon_frame: = 0

var ap_scene_id: = -1

## The level select currently on screen.
var level_select: LevelSelect

var last_world: = -1
var last_level: = -1

# For use with the full coin clear check
var _coin_run_level: Level = null
var _coin_run_collected: Dictionary[String, bool] = {}

var is_deathlink: bool
var _was_ap_playing: bool = false

## Text client banner, this is the best I can do there is ZERO room in this game for a text window
var ap_banner: RichTextLabel

const BANNER_QUEUE_MAX = 100
const BANNER_LEFT_MARGIN = 256.0
const BANNER_MAX_LINES = 2
const BANNER_LINE_HEIGHT = 16.0
const BANNER_SKIP_TYPES: Array[String] = [
	"Tutorial", "CommandResult", "AdminCommandResult", "TagsChanged",
]
const AP_CONSOLE_THEME = preload("res://godot_ap/ui/themes/dark_theme.tres")

var _banner_queue: Array[String] = []
var _banner_timer: Timer


#region MOD/ARCHIPELAGO

func _init() -> void :
	print("AP: pre-initialization")

func _ensure_ap_node() -> void :
	if ProjectSettings.has_setting("autoload/Archipelago"):
		return # a full build handles this for us
	if AP.inst:
		return
	var scene: PackedScene = load(AP_AUTOLOAD_PATH)
	var ap: AP = scene.instantiate()
	ap.name = "Archipelago"
	add_child(ap)
	print("AP: spawned the Archipelago node (no autoload in this build)")

func _enter_tree() -> void :
	print("AP: main initialization")
	_ensure_ap_node()
	get_tree().node_added.connect(_on_any_node_added)
	var master = get_tree().current_scene as Master
	if master:
		ap_scene_id = _register_scene(master, AP_CONNECT_PATH)
		master.child_entered_tree.connect(_on_child_added)
		
		# Deal with mod icons
		var mod_icons: = master.get_node_or_null("HUDMods/ModIcons")
		if mod_icons:
			mod_icons.child_entered_tree.connect(_on_mod_icon_added)
			# update_mods() clears the row and only re-adds vanilla modifiers
			mod_icons.child_exiting_tree.connect(func(_c: Node):
				refresh_spray_icon.call_deferred()
			)

func _ready() -> void :
	print("AP: post-initialization")

	load_config()
	load_coin_ids()
	if config["show_ap_msgs"]:
		_create_banner()
	add_translations()
	_setup_ap_save.call_deferred()

func _setup_ap_save() -> void :
	var ap: = AP.inst
	if not ap:
		push_error("AP: Archipelago node missing, save data unavailable")
		return

	_build_gimmick_icons()
	_register_gimmick_icons()

	ap.roominfo.connect(_on_ap_roominfo)
	ap.connected.connect(_on_ap_connected)
	ap.status_updated.connect(_on_ap_status_updated)

func load_config() -> void :
	config = CONFIG_DEFAULTS.duplicate()
	var file: = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not file:
		return # use defaults if no cooler mod :(
	var saved: Variant = JSON.parse_string(file.get_as_text())
	if saved is Dictionary:
		config.merge(saved, true)

func load_coin_ids() -> void :
	var file: = FileAccess.open(COIN_IDS_PATH, FileAccess.READ)
	if not file:
		push_error("AP: could not open %s" % COIN_IDS_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		coin_ids = parsed

## Returns -1 if the coin has no location
func coin_location_id(level_id: String, coin_path: String) -> int :
	var entry: Variant = coin_ids.get(level_id, {}).get(coin_path)
	if entry is Dictionary and entry.has("id"):
		return int(entry["id"]) # JSON numbers parse as floats
	return -1

## Every coin path the level is known to hold, empty if it has no coins at all.
func level_coin_paths(level_id: String) -> Dictionary:
	var entry: Variant = coin_ids.get(level_id)
	return entry if entry is Dictionary else {}

func _config_option_value_changed(mod: ModLoader.Mod, id: String, value: Variant):
	if mod.id != "jeffdev.uncannycatap":
		return
	config[id] = value
	print("AP: config '%s' is now %s" % [id, value])
	match id:
		"death_link":
			if ap_active():
				AP.inst.set_deathlink(config_toggle("death_link", "death_link"))
			refresh_amnesty_counter()
		"death_link_amnesty":
			refresh_amnesty_counter()
		"chill_mode", "panic_mode":
			sync_ap_mods()

func config_toggle(id: String, slot_key: String) -> bool :
	if not ap_active():
		return false
	match int(config.get(id, 0)):
		1: return true
		2: return false
	return bool(int(AP.inst.conn.slot_data.get(slot_key, 0)))

func chill_mode() -> bool :
	return config_toggle("chill_mode", "chill_mode")

func panic_mode() -> bool :
	return config_toggle("panic_mode", "panic_mode")

## TESTING VALUE, SET TO -1 FOR SLOT DATA
const DEBUG_PRISM_UNLOCK_AMOUNT: int = -1

func prism_current_amount() -> int:
	if not ap_active():
		return Master.game_data.current_pthru.total_prisms
	if AP.inst.conn.slot_data.get("macguffin_goal", 0) == 0:
		return Master.game_data.current_pthru.total_prisms
	return ap_item_count(MACGUFFIN_ITEM_ID)

func prism_unlock_amount() -> int :
	if DEBUG_PRISM_UNLOCK_AMOUNT >= 0:
		return DEBUG_PRISM_UNLOCK_AMOUNT
	if AP.inst.conn.slot_data.get("macguffin_goal", 0) == 0:
		return int(AP.inst.conn.slot_data.get("prism_unlock_amount", 200))
	return int(AP.inst.conn.slot_data.get("macguffin_required", 40))

func _register_scene(master: Master, path: String) -> int:
	var id: = master.game_scene_paths.find(path)
	if id != -1:
		return id
	id = master.game_scene_paths.size()
	master.game_scene_paths.append(path)
	master.packed_game_scenes.resize(master.game_scene_paths.size())
	master.packed_game_scenes[id] = load(path)
	return id

#endregion MOD/ARCHIPELGO


#region AP CONNECTION

func _on_ap_roominfo(conn: ConnectionInfo, _json: Dictionary) -> void :
	var creds: APCredentials = AP.inst.creds
	_use_ap_save_paths(conn.seed_name, creds.slot)

func _on_ap_connected(conn: ConnectionInfo, _json: Dictionary) -> void :
	# Handle AP items received here
	conn.obtained_items.connect(func(_items: Array[NetworkItem]):
		refresh_prism_counter()
		receive_ap_items()
	)

	refresh_gimmick_row()

	APConnectionMemory.store(conn.seed_name)
	suppress_prism_unlocks()
	load_ap_state()
	AP.inst.set_deathlink(config_toggle("death_link", "death_link"))
	conn.deathlink.connect(_on_deathlink_received)
	refresh_amnesty_counter()

func _on_ap_status_updated() -> void :
	var playing: bool = AP.inst.is_ap_connected()
	var dropped: bool = _was_ap_playing and not playing
	_was_ap_playing = playing
	if dropped:
		_confirm_ap_drop()

func _confirm_ap_drop() -> void :
	await get_tree().create_timer(AP_DROP_GRACE).timeout

	if AP.inst.status != AP.inst.APStatus.DISCONNECTED:
		return
	if SaveData.SAVE_PATH == VANILLA_SAVE_PATH:
		return
	print("AP: disconnected, returning to title")

	level_select = null
	last_world = -1
	last_level = -1

	_use_vanilla_save_paths()

	if Master.current:
		Master.current.switch_scene(Master.GameScenes.TITLE)

func _on_ap_printjson(json: Dictionary, _plaintext: String):
	print(json)

## Opens this room's pthru run.
func load_ap_state() -> void :
	var creds: APCredentials = AP.inst.creds
	var pthru: = APPthruData.open(creds.slot)
	if pthru:
		apply_ap_modes(pthru)
		pthru.save_to_file()
	print("AP: state loaded")

func ap_active() -> bool :
	return AP.inst != null and AP.inst.is_ap_connected() and AP.inst.conn != null

func has_ap_item(item_id: int) -> bool :
	if not ap_active():
		return false
	var has := false
	for item in AP.inst.conn.received_items:
		if item.id == item_id:
			has = true
	return has

func ap_item_count(item_id: int) -> int :
	if not ap_active():
		return 0
	var count: = 0
	for item in AP.inst.conn.received_items:
		if item.id == item_id:
			count += 1
	return count

#endregion AP CONNECTION


#region SAVE DATA

func _use_ap_save_paths(seed_name: String, slot_name: String) -> void :
	var dir: = AP_SAVES_DIR.path_join(("%s_%s" % [seed_name, slot_name]).validate_filename())
	SaveData.SAVE_PATH = dir.path_join("save_data.ini")
	PthruData.PTHRUS_DIR = dir.path_join("pthrus/")
	DirAccess.make_dir_recursive_absolute(PthruData.PTHRUS_DIR)
	_reload_profile()
	print("AP: save profile -> %s" % dir)

## Hands the vanilla paths back when leaving a room.
func _use_vanilla_save_paths() -> void :
	if SaveData.SAVE_PATH == VANILLA_SAVE_PATH:
		return
	SaveData.SAVE_PATH = VANILLA_SAVE_PATH
	PthruData.PTHRUS_DIR = VANILLA_PTHRUS_DIR
	_reload_profile()
	print("AP: save profile -> local")

func _reload_profile() -> void :
	Master.game_data.current_pthru = null
	Master.save_data = SaveData.new()

	if SaveData.SAVE_PATH != VANILLA_SAVE_PATH:
		for k in GIMMICK_ICON_SPECS:
			if not Master.save_data.unlocks.has(k):
				Master.save_data.unlocks[k] = false

	var loaded: = Master.save_data.load_save()
	if not loaded and not FileAccess.file_exists(SaveData.SAVE_PATH):
		Master.save_data.seen_cutscenes = [&"ToW1", &"ToW2", &"ToW3", &"ToW4", &"ToW5", &"Ending", &"FinalResults"]
		Master.save_data.unlocks.set(&"game_peak_hunter", true)
		Master.save_data.unlocks.set(&"extra_costumes", true)
		Master.save_data.current_costume = &"canny"
		Master.save_data.write_save()

func apply_ap_modes(pthru: PthruData) -> void :
	if pthru.modifiers == null:
		pthru.modifiers = Modifiers.new()
	pthru.modifiers.mods["easy_mode"] = chill_mode()
	pthru.modifiers.mods["hard_mode"] = panic_mode()
	# Not a vanilla modifier, so it has to be added to the list by hand
	pthru.modifiers.mods[SPRAY_MOD_NAME] = spray_count() > 0

# MODIFIERS, not mods, to be clear
func sync_ap_mods() -> void :
	if not ap_active():
		return 
	var pthru: PthruData = Master.game_data.current_pthru
	if not pthru or not Master.save_data:
		return
	if pthru.modifiers == null:
		pthru.modifiers = Modifiers.new()
	pthru.modifier_check()
	apply_ap_modes(pthru)

	for qty_key in Master.save_data.ap_mod_qty:
		var mod_name: = String(qty_key).trim_prefix("mod_").trim_suffix("_qty")
		if pthru.modifiers.mods.has(mod_name):
			pthru.modifiers.mods[mod_name] = Master.save_data.ap_mod_qty[qty_key] > 0

	pthru.save_to_file()
	Master.save_data.write_save()

	# Update the icons
	if Master.current:
		Master.current.update_mods(pthru.modifiers)
		refresh_spray_icon()

var _opening_presents: = false
var _receiving_items: = false

func _present_window_open() -> bool :
	if not is_instance_valid(Master.current):
		return false
	var eater: = Master.current.get_node_or_null(^"HUDMods/InputEater") as CanvasItem
	return eater != null and eater.visible

func receive_ap_items() -> void :
	if _receiving_items or not ap_active():
		return
	_receiving_items = true
	while _present_window_open():
		await get_tree().process_frame
		if not ap_active() or not is_instance_valid(Master.current):
			_receiving_items = false
			return

	var conn: = AP.inst.conn
	while Master.save_data.ap_item_index < conn.received_items.size():
		var item: = conn.received_items[Master.save_data.ap_item_index]
		Master.save_data.ap_item_index += 1
		if item == null:
			continue

		if ITEM_ID_TO_KEYS.has(item.id):
			var item_key: String = ITEM_ID_TO_KEYS[item.id]
			# By key, not by id range, the spray modifier lives outside that range
			if item_key.begins_with("mod_"):
				var qty_key: = StringName(item_key + "_qty")
				Master.save_data.ap_mod_qty[qty_key] = Master.save_data.ap_mod_qty.get(qty_key, 0) + 1
			else:
				restore_unlock_key(StringName(item_key)) # in case it is held back
				Master.current.award_unlock(item_key)

	Master.save_data.write_save()

	sync_ap_mods()
	refresh_gimmick_row()
	if is_instance_valid(level_select):
		apply_ap_locks(level_select)
		open_presents_now()
	_receiving_items = false

func open_presents_now() -> void :
	if not ap_active() or not is_instance_valid(Master.current):
		return
	if _opening_presents or Master.current.unopened_presents.is_empty():
		return
	_opening_presents = true
	await Master.current.open_presents()
	_opening_presents = false

#endregion SAVE DATA


#region LOCATION IDS AND CHECKS

## "3-11" -> [3, 10]. World P is index 6, world E is 7
func parse_level_id(id: String) -> Array:
	var parts: = id.split("-")
	var world: int
	match parts[0]:
		"P": world = 6
		"E": world = 7
		_: world = parts[0].to_int()
	# Endless levels start from 0 even in the select display lol
	var level: = parts[1].to_int() if world == 7 else parts[1].to_int() - 1
	return [world, level]

func goal_level() -> Vector2i :
	if not ap_active():
		return Vector2i( - 1, - 1)
	var idx: int = int(AP.inst.conn.slot_data.get("goal_level", 0))
	if idx < 0 or idx >= GOAL_LEVELS.size():
		return Vector2i( - 1, - 1)
	return GOAL_LEVELS[idx]

func is_goal_level(world: int, level: int) -> bool :
	return goal_level() == Vector2i(world, level + 1)

func send_minigame_checks(game_offset: int, score_gap: int, score_value: int) -> void :
	if not ap_active():
		return
	@warning_ignore("integer_division")
	var reached: = score_value / score_gap
	for i in range(1, reached + 1):
		var loc: = BASE_ID + game_offset + i - 1
		if AP.inst.location_exists(loc) and not AP.inst.location_checked(loc):
			print("AP: threshold %d reached, sending %d" % [i * score_gap, loc])
			AP.inst.collect_location(loc)

func all_coins_location_id(world: int, level_idx: int) -> int :
	return BASE_ID + ALL_COIN_OFFSET + (100 * world) + level_idx

## Starts tracking coins upon starting a level.
func begin_coin_run(lvl: Level) -> void :
	_coin_run_level = lvl
	_coin_run_collected.clear()

## Records a coin pickup and sends the full clear check once the level is emptied.
func mark_coin_collected(lvl: Level, coin_path: String) -> void :
	if not ap_active() or not is_instance_valid(lvl):
		return
	if lvl != _coin_run_level:
		begin_coin_run(lvl) # a level we never saw start, track it from here on
	_coin_run_collected[coin_path] = true
	_send_full_clear(lvl)

func _send_full_clear(lvl: Level) -> void :
	var paths: = level_coin_paths(lvl.ID)
	if paths.is_empty():
		return
	var parsed: = parse_level_id(lvl.ID)
	var loc: = all_coins_location_id(parsed[0], parsed[1])
	if not AP.inst.location_exists(loc) or AP.inst.location_checked(loc):
		return
	for path in paths:
		if not _coin_run_collected.has(path):
			return
	print("AP: all %d coins in %s collected, sending %d" % [paths.size(), lvl.ID, loc])
	AP.inst.collect_location(loc)

const SMILEY_COLOURS: Array[String] = ["Red", "Green", "Blue", "Yellow", "Orange"]

func ap_level_locations(world: int, level_idx: int) -> Array:
	if not ap_active():
		return []
	var complete_id: = BASE_ID + (100 * world) + level_idx
	var candidates: = [
		["Complete", complete_id],
		["Good", complete_id + GOOD_OFFSET],
		["Peak", complete_id + PEAK_OFFSET],
	]

	if AP.inst.conn.slot_data.get("coinsanity", 2) == 2:
		candidates.append(["All Coins", complete_id + ALL_COIN_OFFSET])

	for colour in SMILEY_COLOURS.size():
		candidates.append([
			SMILEY_COLOURS[colour],
			BASE_ID + SMILEY_OFFSET + (100 * world) + (level_idx * 5) + colour,
		])

	var found: = []
	for entry in candidates:
		if AP.inst.location_exists(entry[1]):
			found.append(entry)
	return found

## Lists which of a level's checks have been sent.
func ap_check_summary(world: int, level_idx: int) -> String :
	if not ap_active():
		return ""

	var locations: = ap_level_locations(world, level_idx)
	if locations.is_empty():
		return "AP: no checks here"

	var lines: PackedStringArray = []
	var smileys: = ""
	for entry in locations:
		var mark: = "✓" if AP.inst.location_checked(entry[1]) else "✕"
		if entry[0] in SMILEY_COLOURS:
			smileys += " %s [%s]" % [entry[0].left(1), mark]
		else:
			lines.append("%s %s" % [mark, entry[0]])

	if not smileys.is_empty():
		lines.append("Smileys:" + smileys)

	return "\nChecks:\n" + "\n".join(lines)

#endregion LOCATION IDS AND CHECKS


#region SCENE HOOKS

func _on_child_added(node: Node):
	if node is GameLoader:
		cooler_mods_node = get_tree().root.get_node("ModLoader/justsomejello_coolermods")
		if cooler_mods_node:
			cooler_mods_node.connect("config_option_value_changed", _config_option_value_changed)
	if node.name == "PThru":
		_PThru_start(node)
		node.ready.connect(func():
			if ap_active():
				build_prism_counter(node.pthru_HUD)
				build_amnesty_counter(node.pthru_HUD)
		)
	if node.name == "TitleScreen" and node is Menu:
		_TitleScreen_start(node)
	if node is PthruSelect and ap_active():
		node.ready.connect(_lock_pthru_file_actions.bind(node))
		node.ready.connect(_show_ap_completion.bind(node))
	if node is LevelSelect:
		if not ap_active():
			level_select = null
			return # vanilla level select handles its own locks and stats
		level_select = node
		node.ready.connect(apply_ap_locks.bind(node))
		node.ready.connect(hook_level_stats.bind(node))
		node.ready.connect(func():
			if ap_active():
				build_prism_counter(node.pthru_HUD)
				build_gimmick_row(node.pthru_HUD)
				build_amnesty_counter(node.pthru_HUD)

				if last_world >= 0:
					node._look_at_world(last_world)
		)
		_LevelSelect_start(node)

func _on_any_node_added(node: Node):
	if not ap_active():
		return

	if node is SmileyRing:
		var ring := node as SmileyRing
		(ring.get_node("win") as AudioStreamPlayer).finished.connect(
			func():
				if not ap_active():
					return
				var level_idx = parse_level_id(ring.level.ID)
				if ring.color.to_html(false) == "ff8c8c" or ring.color.to_html(false) == "ff768c" or ring.color.to_html(false) == "ff8080":
					print("AP: red smiley collected, sending to server")
					AP.inst.collect_location(BASE_ID + SMILEY_OFFSET + (100 * level_idx[0]) + (level_idx[1] * 5) + 0)
				if ring.color.to_html(false) == "8cff9a" or ring.color.to_html(false) == "80ff95":
					print("AP: green smiley collected, sending to server")
					AP.inst.collect_location(BASE_ID + SMILEY_OFFSET + (100 * level_idx[0]) + (level_idx[1] * 5) + 1)
				if ring.color.to_html(false) == "8cd9ff" or ring.color.to_html(false) == "80d4ff" or ring.color.to_html(false) == "90eeff":
					print("AP: blue smiley collected, sending to server")
					AP.inst.collect_location(BASE_ID + SMILEY_OFFSET + (100 * level_idx[0]) + (level_idx[1] * 5) + 2)
				if ring.color.to_html(false) == "ffee8c":
					print("AP: yellow smiley collected, sending to server")
					AP.inst.collect_location(BASE_ID + SMILEY_OFFSET + (100 * level_idx[0]) + (level_idx[1] * 5) + 3)
				if ring.color.to_html(false) == "ffbf66":
					print("AP: orange smiley collected, sending to server")
					AP.inst.collect_location(BASE_ID + SMILEY_OFFSET + (100 * level_idx[0]) + (level_idx[1] * 5) + 4)
				,CONNECT_ONE_SHOT
		)


	# Both of these award a costume that belongs to the item pool
	if node is RobertCutscene:
		hold_back_unlock(node, &"costume_nothing")
	if node is EditorEndScreen:
		hold_back_unlock(node, &"costume_builder")

	if node is Ghost:
		node.ready.connect(_hook_ghost.bind(node), CONNECT_ONE_SHOT)

	if node is Block and node.dblock_score and not has_gimmick(&"ap_tiles"):
		_lock_block(node)
		node.ready.connect(func():
			var mat: ShaderMaterial = node.special_graphic.material
			if mat:
				mat = mat.duplicate()
				mat.set_shader_parameter("MidShade", Color.RED)
				mat.set_shader_parameter("HighShade", Color.RED)
				node.special_graphic.material = mat
			)

	if node is Level and not has_gimmick(&"ap_switch"):
		node.ready.connect(func():
			var empty_switch_tiles: Array[TileMapLayer] = []
			node.switch_tiles = empty_switch_tiles
		)

	if node is SwitchBlock and not has_gimmick(&"ap_switch"):
		node.modulate = Color.RED

	if node is Portal and not has_gimmick(&"ap_portal"):
		node.inactive = true
		node.modulate = Color.RED

	if node is Dog and not has_gimmick(&"ap_dog"):
		node.speed = 0;
		node.modulate = Color.RED

	if node is JumpPad and not has_gimmick(&"ap_jump"):
		node.set_deferred("monitoring", false)
		node.modulate = Color.RED

	if node is Collectible:
		# Stop/Go Markers
		if node.does_speed:
			if node.set_speed == 0.0:
				if not has_gimmick(&"ap_stop"):
					node.set_deferred("monitoring", false)
					node.modulate = Color.RED
			elif node is not Key and not has_gimmick(&"ap_go"):
				node.set_deferred("monitoring", false)
				node.modulate = Color.RED

		# Coins
		if node.coin_multiply and not node.scene_file_path.ends_with("coaster_coin.tscn"):
			node.ready.connect(func():
				var lvl: Level = node.level
				var coin_path: = str(lvl.get_path_to(node))
				var loc: = coin_location_id(lvl.ID, coin_path)
				if loc < 0:
					print("AP: no coin location for %s/%s" % [lvl.ID, coin_path])
					return
				elif not AP.inst.location_checked(loc) and AP.inst.conn.slot_data.get("coinsanity", 0) == 1:
					node.modulate = Color.GREEN

				node.collected.connect(func():
					if not ap_active():
						return
					if AP.inst.location_exists(loc) and not AP.inst.location_checked(loc):
						print("AP: coin %s/%s collected, sending %d" % [lvl.ID, coin_path, loc])
						AP.inst.collect_location(loc)
					mark_coin_collected(lvl, coin_path)
				, CONNECT_ONE_SHOT)
			, CONNECT_ONE_SHOT)

	if node is Key and not has_gimmick(&"ap_keys"):
		node.set_deferred("monitoring", false)
		node.modulate = Color.RED

	if node is Nuke and not has_gimmick(&"ap_nuke"):
		node.set_deferred("monitoring", false)
		node.modulate = Color.RED

	if node is HorseGoal and not has_gimmick(&"ap_golf"):
		node.ready.connect(func():
			node.hitbox_area.set_deferred(&"disabled", true)
		)
		node.modulate = Color.RED

	if node is LandMine and not has_gimmick(&"ap_mine"):
		node.get_node("Detector").set_deferred("monitoring", false)
		node.modulate = Color.RED

	if node is Metronome and not has_gimmick(&"ap_metronome"):
		node.TriggerEvery = 99999
		node._label.text = "LOCKED!"
		for s in [node._graphic, node._graphic.get_node("MetronomeStick")]:
			s.material = null
			s.modulate = Color.RED
		node.ready.connect(func():
			node._trigger()
			for t in node.TriggerList:
				if t and t.material is ShaderMaterial:
					var m: ShaderMaterial = t.material.duplicate()
					m.set_shader_parameter("HighShade", Color.RED)
					m.set_shader_parameter("MidShade", Color(0.7, 0, 0))
					m.set_shader_parameter("LowShade", Color(0.35, 0, 0))
					t.material = m
		)


	# Force disable prism gates as they aren't relevant for AP
	if node is PrismGate:
		node.prism_number = 0
		
	# Force remove easy mode ending things
	if node.get_script() == EASY_MODE_ENDING:
		var to_add: Array = node.objects_to_add.duplicate()
		node.set_script(null) # before its _ready runs
		for obj in to_add:
			if is_instance_valid(obj):
				obj.queue_free()


	# Minigames
	if node is UncannyDashGame:
		node.score_changed.connect(func(value: int):
			send_minigame_checks(DASH_OFFSET, 25, value)
		)

	if node is BartGame:
		node.round_changed.connect(func(value: int):
			send_minigame_checks(BORT_OFFSET, 1, value)
		)

	if node is MeowlLevel:
		node.score_changed.connect(func(value: int):
			send_minigame_checks(MEOWLS_OFFSET, 10000, value)
		)

func _PThru_start(node: PThru):
	if not ap_active():
		return
	node.world_peak_unlocks.clear()
	suppress_prism_unlocks()
	node.child_entered_tree.connect(_PThru_on_child_added)

func _PThru_on_child_added(node: Node):
	if node is Level:
		if not ap_active():
			return

		var lvl := node as Level
		begin_coin_run(lvl)
		var parsed: = parse_level_id(lvl.ID)
		var lvl_world: int = parsed[0]
		var lvl_idx: int = parsed[1]
		lvl.unlocks = [];
		lvl.peak_unlocks = [];

		var level_item: = BASE_ID + (100 * lvl_world) + lvl_idx
		var world_item: = BASE_ID + WORLD_ITEM_OFFSET + (lvl_world - 1)
		if not has_ap_item(level_item) and not has_ap_item(world_item) and not lvl_world == 0 and not is_goal_level(lvl_world, lvl_idx):
			_kick_to_level_select(lvl_world, lvl_idx)
			return
		if is_goal_level(lvl_world, lvl_idx) and not prism_current_amount() >= prism_unlock_amount():
			_kick_to_level_select(lvl_world, lvl_idx)
			return

		# Handle transitioning to out of bounds endless level because this is a weird custom world lol
		var pthru: = PThru.current
		if lvl_world == 7 and lvl_idx >= Master.game_data.worlds[7].total_levels() - 1:
			if lvl.progress.is_connected(pthru.level_switch):
				lvl.progress.disconnect(pthru.level_switch)
			lvl.progress.connect(func(trans_mode: int):
				if trans_mode not in [PThru.LEVEL_TRANSITION.NORMAL, PThru.LEVEL_TRANSITION.SKIP]:
					pthru.level_switch(trans_mode) 
					return
				if trans_mode == PThru.LEVEL_TRANSITION.NORMAL:
					pthru.write_level_data(lvl_world, lvl_idx, lvl.hideScoring)
				pthru.master.thinker.visible = true
				_kick_to_level_select(lvl_world, lvl_idx)
			)

		# Beating the goal level goes straight to the final results instead of the next level
		if is_goal_level(lvl_world, lvl_idx):
			if lvl.progress.is_connected(pthru.level_switch):
				lvl.progress.disconnect(pthru.level_switch)
			lvl.progress.connect(func(trans_mode: int):
				var peak_hunter_click: bool = trans_mode == PThru.LEVEL_TRANSITION.WIN_RESET \
					and Input.is_action_just_pressed(&"Click") and not Input.is_action_just_pressed(&"Restart")
				if trans_mode != PThru.LEVEL_TRANSITION.NORMAL and not peak_hunter_click:
					pthru.level_switch(trans_mode)
					return
				pthru.write_level_data(lvl_world, lvl_idx, lvl.hideScoring)
				pthru.master.thinker.visible = true
				lvl.queue_free()
				pthru.overlay.emit(Master.GameScenes.FINAL_RESULTS)
				pthru.play_music.emit(Master.Music.NONE, 1.0)
			)

		last_world = lvl_world
		last_level = lvl_idx

		lvl.progress.connect(func(trans_mode: int):
			if lvl.mode == lvl.MODES.NORMAL and ap_active():
				if trans_mode in [PThru.LEVEL_TRANSITION.NORMAL, PThru.LEVEL_TRANSITION.WIN_RESET, PThru.LEVEL_TRANSITION.GOLDEN_TEE]:
					# Check for goal
					if prism_current_amount() >= prism_unlock_amount() and is_goal_level(lvl_world, lvl_idx):
						AP.inst.set_client_status(AP.inst.ClientStatus.CLIENT_GOAL)
					else:
						# Check for peak
						var complete_loc_id: int = BASE_ID + (100 * lvl_world) + lvl_idx
						var peak_loc_id: int = complete_loc_id + PEAK_OFFSET
						var good_loc_id: int = complete_loc_id + GOOD_OFFSET
						var rank: int = 5 if lvl.hideScoring else lvl.HUD.rank_calc
						var rank_difficulty: int = int(AP.inst.conn.slot_data.get("rank_check_difficulty", 1))
						var required_rank: int = Level.Ranks.OK if rank_difficulty == 0 else Level.Ranks.SWAG
						if rank == 5:
							var loc_ids: Array[int] = [complete_loc_id, good_loc_id, peak_loc_id]
							AP.inst.collect_locations(loc_ids)
						elif rank >= required_rank:
							var loc_ids: Array[int] = [complete_loc_id, good_loc_id]
							AP.inst.collect_locations(loc_ids)
						else:
							AP.inst.collect_location(complete_loc_id)
						
					for mod in Master.save_data.ap_mod_qty:
						if mod == SPRAY_QTY_KEY:
							continue # only spent on a save, never on a clear
						if Master.save_data.ap_mod_qty[mod] > 0:
							Master.save_data.ap_mod_qty[mod] -= 1
					sync_ap_mods()

			refresh_prism_counter()
		)

		const DEATH_MESSAGES := {
			Level.DEATH_TYPES.NORMAL: " got jumpscared by the Uncanny Cat!",
			Level.DEATH_TYPES.O_B: " fell out of bounds.",
			Level.DEATH_TYPES.BACKROOMS: " fell into the backrooms.",
			Level.DEATH_TYPES.WALL_STUCK: " got stuck in a wall.",
			Level.DEATH_TYPES.HORSE: " got trampled by the horse!",
			Level.DEATH_TYPES.WATER: " drowned.",
		}

		# DeathLink
		lvl.died.connect(func(type: Level.DEATH_TYPES, _cause: Node2D):
			if lvl.mode != Level.MODES.NORMAL or lvl.test_mode:
				return
			if is_deathlink:
				return
			if not ap_active() or not AP.inst.is_deathlink():
				return
			if not handle_deathlink_amnesty():
				return
			AP.inst.conn.send_deathlink(AP.inst.creds.slot + DEATH_MESSAGES.get(type, " died"))
		)

func _TitleScreen_start(node: Menu):
	node.set_script(AP_TITLE_SCREEN)
	node.set("ap_scene_id", ap_scene_id)
	if ap_active():
		AP.inst.ap_disconnect()

	restore_prism_unlocks()
	_use_vanilla_save_paths()

func _LevelSelect_start(node: LevelSelect):
	if ap_active():
		node.CURRENT_PTHRU.furthest_level_ID = 200;
		node.CURRENT_PTHRU.furthest_world_ID = 7;
		node.CURRENT_PTHRU.can_swim = true;

		sync_ap_mods()

		node.CURRENT_PTHRU.save_to_file();

func _kick_to_level_select(world: int, level: int) -> void :
	print("AP: level %d-%d is locked, returning to level select" % [world, level + 1])
	LevelSelect.current_play_world = world
	LevelSelect.current_play_level = level
	var pthru: = PThru.current
	if pthru:
		pthru.switch.emit.call_deferred(Master.GameScenes.PTHRU_MENU)

#endregion SCENE HOOKS


#region WORLD LOCKS

func suppress_prism_unlocks() -> void :
	if not is_instance_valid(Master.current):
		return
	if Master.current.prism_count_unlocks.is_empty():
		return
	_vanilla_prism_unlocks = Master.current.prism_count_unlocks.duplicate()
	Master.current.prism_count_unlocks = {}
	print("AP: vanilla prism milestone costumes disabled")

# This is for play without AP functionality
func restore_prism_unlocks() -> void :
	if _vanilla_prism_unlocks.is_empty() or not is_instance_valid(Master.current):
		return
	Master.current.prism_count_unlocks = _vanilla_prism_unlocks.duplicate()
	_vanilla_prism_unlocks = {}
	print("AP: vanilla prism milestone costumes restored")

func hold_back_unlock(node: Node, key: StringName) -> void :
	if not ap_active() or not Master.save_data:
		return
	if Master.save_data.unlocks.get(key, true):
		return
	Master.save_data.unlocks.erase(key)
	print("AP: holding back the vanilla '%s' unlock" % key)
	node.tree_exited.connect(restore_unlock_key.bind(key), CONNECT_ONE_SHOT)

func restore_unlock_key(key: StringName) -> void :
	if not Master.save_data or Master.save_data.unlocks.has(key):
		return
	Master.save_data.unlocks[key] = false

func has_gimmick(key: StringName) -> bool :
	if not ap_active():
		return true
	if not int(AP.inst.conn.slot_data.get("gimmick_lock", 1)):
		return true
	return Master.save_data.unlocks.get(key, false)

# Sets up blocking breakable tiles
func _lock_block(b: Block) -> void :
	var saved: = {}
	for p in b.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			saved[p.name] = b.get(p.name)
	var saved_size: Vector2 = saved["size"]
	saved.erase("size")

	b.set_script(AP_BLOCK)
	for k in saved:
		b.set(k, saved[k])
	b.size = saved_size
	b.modulate = Color.RED

func ap_level_locked(world: int, level: int) -> bool :
	# World 0 is always playable
	if world == 0 or not ap_active():
		return false
	if prism_current_amount() >= prism_unlock_amount():
		if is_goal_level(world, level):
			return false
	return not has_ap_item(BASE_ID + (100 * world) + level) \
		and not has_ap_item(BASE_ID + WORLD_ITEM_OFFSET + (world - 1))

func ap_level_disabled(world: int, level: int) -> bool :
	if not ap_active() or is_goal_level(world, level):
		return false
	return not AP.inst.location_exists(BASE_ID + (100 * world) + level)

func apply_ap_locks(sel: LevelSelect) -> void :
	if not ap_active():
		return
	for child in sel.button_group.get_children():
		var butt: = child as LevelSelectButton
		if not butt:
			continue
		butt.locked.z_index = 0

		if butt.ID.is_empty():
			continue
		var parts: = butt.ID.split("-")
		var world: = parts[0].to_int()
		var level: = parts[1].to_int() - 1

		if ap_level_disabled(world, level):
			butt.self_modulate = Color.RED

		if is_goal_level(world, level):
			butt.self_modulate = GOAL_TINT

		butt.set_lock(ap_level_locked(world, level))

#endregion WORLD LOCKS


#region LEVEL SELECT UI

## 0.0 - 1.0 of completion
func ap_completion() -> float :
	if not ap_active():
		return 0.0
	var locs: Dictionary = AP.inst.conn.slot_locations
	if locs.is_empty():
		return 0.0
	var done: = 0
	for id in locs:
		if locs[id]:
			done += 1
	return float(done) / float(locs.size())

## Replace the vanilla level/prism completion figure with AP check progress.
func _show_ap_completion(sel: PthruSelect) -> void :
	var pct: = ap_completion()
	for child in sel.button_group.get_children():
		var b: = child as PthruButton
		if not b:
			continue
		b.completion.text = "%d%%" % int(pct * 100.0)
		if pct >= 1.0:
			b.mark_peaked()
			continue
		b.self_modulate = Color.WHITE
		b.peak_sparkles.visible = false

func _lock_pthru_file_actions(sel: PthruSelect) -> void :
	var new_btn: Node2D = sel.get_node("NewButton")
	new_btn.process_mode = Node.PROCESS_MODE_DISABLED
	new_btn.modulate = Color(1, 1, 1, 0.35)
	
	var ps_mode_btn: Node2D = sel.get_node("PSModeButton")
	ps_mode_btn.process_mode = Node.PROCESS_MODE_DISABLED
	ps_mode_btn.modulate = Color(1, 1, 1, 0.35)

func hook_level_stats(sel: LevelSelect) -> void :
	if not ap_active():
		return
	for child in sel.button_group.get_children():
		var butt: = child as LevelSelectButton
		if not butt or butt.ID.is_empty():
			continue
		butt.pressed.connect(_append_ap_stats.bind(sel, butt.ID))

func _append_ap_stats(sel: LevelSelect, id: String) -> void :
	if not ap_active():
		return
	var parts: = id.split("-")
	var world: = parts[0].to_int()
	if world != sel.looking_at_world:
		return
	var summary: = ap_check_summary(world, parts[1].to_int() - 1)
	if summary.is_empty():
		return
	sel.selected_stats.text += "\n" + summary

#endregion LEVEL SELECT UI


#region HUD

func _on_mod_icon_added(icon: Node) -> void:
	if not ap_active() or not Master.save_data:
		return
	var rect: = icon as TextureRect
	if not rect or not rect.texture:
		return

	var mod_name: = rect.texture.resource_path.get_file().get_basename()
	var qty_key: = StringName("mod_" + mod_name + "_qty")
	if not Master.save_data.ap_mod_qty.has(qty_key):
		return

	var qty = Master.save_data.ap_mod_qty[qty_key]
	if qty <= 0:
		return

	var count := Label.new()
	count.text = str(qty)
	count.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count.add_theme_font_size_override("font_size", 14)
	count.add_theme_color_override("font_color", Color.RED)
	count.add_theme_color_override("font_outline_color", Color.BLACK)
	count.add_theme_constant_override("outline_size", 4)
	icon.add_child(count)

# A lil complex to be able to handle animated icons
func _build_gimmick_icons() -> void :
	for k in GIMMICK_ICON_SPECS:
		var spec: Array = GIMMICK_ICON_SPECS[k]
		var atlas: = AtlasTexture.new()
		atlas.atlas = load(spec[0])
		atlas.region = Rect2(0, 0, spec[1], spec[2])
		gimmick_icons[k] = atlas
		if spec[3] > 1:
			_animated_icons.append([atlas, spec[1], spec[3]])

	if _animated_icons.is_empty():
		return
	var ticker: = Timer.new()
	ticker.wait_time = ICON_FRAME_TIME
	ticker.timeout.connect(_step_icon_frames)
	add_child(ticker)
	ticker.start()

func _step_icon_frames() -> void :
	_icon_frame += 1
	for entry in _animated_icons:
		var atlas: AtlasTexture = entry[0]
		var region: Rect2 = atlas.region
		region.position.x = entry[1] * (_icon_frame % int(entry[2]))
		atlas.region = region

func _register_gimmick_icons() -> void :
	if not is_instance_valid(Master.current):
		return
	for child in Master.current.unlock_presents.get_children():
		var present: = child.get_child(0) as UnlockPresent
		if present:
			present.unlock_icons.merge(gimmick_icons)

func make_gimmick_sprite(key: StringName, fps: float = 12.0) -> AnimatedSprite2D:
	var spec: Array = GIMMICK_ICON_SPECS[key]
	var sheet: Texture2D = load(spec[0])

	var frames: = SpriteFrames.new()
	frames.set_animation_speed(&"default", fps)
	frames.set_animation_loop(&"default", true)
	for i in int(spec[3]):
		var atlas: = AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(spec[1] * i, 0, spec[1], spec[2])
		frames.add_frame(&"default", atlas)

	var sprite: = AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.autoplay = &"default"
	return sprite

func build_gimmick_row(hud: CanvasLayer) -> void :
	if not ap_active():
		return
	gimmick_row.clear()
	var step: = GIMMICK_CELL + GIMMICK_PADDING
	var col: = 0
	var row: = 0
	for key in GIMMICK_ICON_SPECS:
		if key == &"ap_golf" or key == &"ap_mine":
			if AP.inst.conn.slot_data.get("world_5_levels", 0) == 0:
				continue
		if key == &"ap_metronome":
			if AP.inst.conn.slot_data.get("world_p_levels", 0) == 0:
				continue
		var spec: Array = GIMMICK_ICON_SPECS[key]
		var sprite: = make_gimmick_sprite(key)
		sprite.scale = Vector2.ONE * (GIMMICK_CELL / maxf(spec[1], spec[2]))
		sprite.position = GIMMICK_ROW_ORIGIN + Vector2(step * col, step * row)
		hud.add_child(sprite)
		gimmick_row[key] = sprite

		col += 1
		if col >= GIMMICK_PER_ROW:
			col = 0
			row += 1
	refresh_gimmick_row()

func refresh_gimmick_row() -> void :
	for key in gimmick_row:
		var sprite: AnimatedSprite2D = gimmick_row[key]
		if not is_instance_valid(sprite):
			continue
		sprite.modulate = Color.WHITE if has_ap_item(ITEM_ID_TO_KEYS.find_key(key)) else GIMMICK_LOCKED_TINT

func build_prism_counter(hud: PthruHUD) -> void :
	hud.tprism_text.position = Vector2(180, 144)
	var prism: AnimatedSprite2D = hud.get_node("Prism")
	prism.position = Vector2(165, 152)
	if not prism_labels.has(hud.tprism_text):
		prism_labels.append(hud.tprism_text)
	refresh_prism_counter()

func refresh_prism_counter() -> void :
	if not ap_active():
		return
	var text: = str(prism_current_amount()) + " / %s" % prism_unlock_amount()
	for i in range(prism_labels.size() - 1, -1, -1):
		var label: = prism_labels[i]
		if not is_instance_valid(label):
			prism_labels.remove_at(i)
			continue
		label.text = text

func build_amnesty_counter(hud: CanvasLayer) -> void :
	var label: = hud.get_node_or_null(NodePath(AMNESTY_LABEL_NAME)) as Label
	if not label:
		label = Label.new()
		label.name = AMNESTY_LABEL_NAME
		label.position = AMNESTY_LABEL_RECT.position
		label.size = AMNESTY_LABEL_RECT.size
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font", HUD_FONT)
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", AMNESTY_LABEL_COLOR)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		hud.add_child(label)
	if not amnesty_labels.has(label):
		amnesty_labels.append(label)
	refresh_amnesty_counter()

func refresh_amnesty_counter() -> void :
	var show_counter: bool = (is_instance_valid(Master.save_data)
		and ap_active() and AP.inst.is_deathlink())
	var text: String = ""
	if show_counter:
		text = "Deaths: %d / %d" % [Master.save_data.ap_deathlink_amnesty, deathlink_amnesty()]
	for i in range(amnesty_labels.size() - 1, -1, -1):
		var label: = amnesty_labels[i]
		if not is_instance_valid(label):
			amnesty_labels.remove_at(i)
			continue
		label.visible = show_counter
		label.text = text

#endregion HUD


#region UNCANNY CAT SPRAY

func spray_count() -> int :
	if not is_instance_valid(Master.save_data):
		return 0
	if not ap_active():
		return 0
	if AP.inst.conn.slot_data.get("buff_uncanny_cat_spray", 0) == 0:
		return 0
	return int(Master.save_data.ap_mod_qty.get(SPRAY_QTY_KEY, 0))

func _hook_ghost(ghost: Ghost) -> void :
	if not ap_active() or not is_instance_valid(ghost):
		return
	var lvl: Level = ghost.level
	if not is_instance_valid(lvl):
		return
	if ghost.caught.is_connected(lvl.death):
		ghost.caught.disconnect(lvl.death)
	ghost.caught.connect(func(type: Level.DEATH_TYPES, cause: Node2D):
		if not spend_spray(lvl):
			lvl.death(type, cause)
			return
		if ghost.parry_stun <= 0:
			ghost.stored_velocity = ghost.velocity
		ghost.parry_stun = Player.PARRY_TIME
		ghost.velocity = Vector2.ZERO
	)

func spend_spray(lvl: Level) -> bool :
	if not ap_active() or lvl.test_mode or lvl.mode == Level.MODES.DEMO:
		return false
	var left: = spray_count()
	if left <= 0:
		return false
	Master.save_data.ap_mod_qty[SPRAY_QTY_KEY] = left - 1
	Master.save_data.write_save()
	print("AP: uncanny cat spray used, %d left" % (left - 1))
	sync_ap_mods()
	return true

## update_mods() only draws the vanilla modifier icons, so ours is kept here.
func refresh_spray_icon() -> void :
	if is_instance_valid(_spray_icon) and _spray_icon.is_queued_for_deletion():
		_spray_icon = null # the row was wiped, it just has not left the tree yet
	if not ap_active() or spray_count() <= 0:
		if is_instance_valid(_spray_icon):
			_spray_icon.queue_free()
		_spray_icon = null
		return
	if is_instance_valid(_spray_icon) or not is_instance_valid(Master.current):
		return
	var row: = Master.current.get_node_or_null(^"HUDMods/ModIcons") as Container
	if not row:
		return
	var icon: = TextureRect.new()
	icon.name = &"APUncannyCatSpray"
	icon.texture = SPRAY_ICON
	icon.pivot_offset = SPRAY_ICON.get_size() * 0.5
	_spray_icon = icon
	row.add_child(icon) # _on_mod_icon_added() stamps the count on it

#endregion UNCANNY CAT SPRAY


#region DEATHLINK

func deathlink_amnesty() -> int :
	return maxi(1, int(config.get("death_link_amnesty", 5)))

func handle_deathlink_amnesty() -> bool :
	if not Master.save_data:
		return true
	var amnesty: = deathlink_amnesty()
	var deaths: int = Master.save_data.ap_deathlink_amnesty + 1
	var send: bool = deaths >= amnesty
	Master.save_data.ap_deathlink_amnesty = 0 if send else deaths
	Master.save_data.write_save()
	refresh_amnesty_counter()
	return send

func _on_deathlink_received(_source: String, _cause: String, _json: Dictionary) -> void:
	var pthru := PThru.current
	if not pthru or not is_instance_valid(pthru.current_level):
		return 
	var lvl := pthru.current_level
	if not lvl.level_active:
		return
	is_deathlink = true
	lvl.death(Level.DEATH_TYPES.NORMAL)
	is_deathlink = false

#endregion DEATHLINK


#region MESSAGE BANNER

func _create_banner() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	ap_banner = RichTextLabel.new()
	ap_banner.bbcode_enabled = true
	ap_banner.scroll_active = false
	ap_banner.fit_content = false
	ap_banner.clip_contents = true
	ap_banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	ap_banner.offset_left = BANNER_LEFT_MARGIN
	ap_banner.offset_bottom = BANNER_LINE_HEIGHT * BANNER_MAX_LINES
	ap_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ap_banner.add_theme_font_size_override("normal_font_size", 12)
	ap_banner.add_theme_color_override("font_outline_color", Color.BLACK)
	ap_banner.add_theme_constant_override("outline_size", 4)
	layer.add_child(ap_banner)

	_banner_timer = Timer.new()
	_banner_timer.one_shot = true
	_banner_timer.wait_time = config["ap_msg_queue_time"]
	_banner_timer.timeout.connect(_advance_banner)
	add_child(_banner_timer)

	AP.inst.printjson.connect(_on_printjson)

func queue_banner(bbcode: String) -> void :
	if _banner_queue.size() >= BANNER_QUEUE_MAX:
		return
	_banner_queue.append(bbcode)
	if _banner_timer.is_stopped():
		_advance_banner()

func _advance_banner() -> void :
	if _banner_queue.is_empty():
		ap_banner.text = ""
		return
	ap_banner.text = "[center]%s[/center]" % _banner_queue.pop_front()
	_banner_timer.start()

# This deals with GodotAP color stuff
func ap_hex(special: AP.SpecialColor) -> String :
	var rich: = AP.special_to_rich_color(special)
	if rich == AP.RichColor.NIL:
		return "ffffff"
	var key: = "rich_%s" % AP.RichColor.find_key(rich).to_lower()
	if AP_CONSOLE_THEME.has_color(key, "Console_Label"):
		return AP_CONSOLE_THEME.get_color(key, "Console_Label").to_html(false)
	return "ffffff"

func printjson_bbcode(elems: Array) -> String :
	var out: = ""
	for elem in elems:
		var txt: String = elem["text"]
		if txt.is_empty():
			continue
		if "Warning: your client does not support" in txt:
			continue
		var special: = AP.SpecialColor.UI_MESSAGE
		var coloured: = false
		match elem.get("type", "text"):
			"player_id":
				var pid: = int(txt)
				txt = AP.inst.conn.get_player(pid).name
				special = (AP.SpecialColor.OWN_PLAYER if pid == AP.inst.conn.player_id
					else AP.SpecialColor.ANY_PLAYER)
				coloured = true
			"item_id":
				var pid: = int(elem["player"])
				txt = AP.inst.conn.get_gamedata_for_player(pid).get_item_name(int(txt))
				special = AP.get_item_class_color(int(elem["flags"]))
				coloured = true
			"location_id":
				var pid: = int(elem["player"])
				txt = AP.inst.conn.get_gamedata_for_player(pid).get_loc_name(int(txt))
				special = AP.SpecialColor.LOCATION
				coloured = true
		txt = txt.replace("[", "[lb]")
		out += ("[color=#%s]%s[/color]" % [ap_hex(special), txt]) if coloured else txt
	return out

func _on_printjson(json: Dictionary, plaintext: String) -> void :
	if json.get("type", "Chat") in BANNER_SKIP_TYPES:
		return
	var data: Array = json.get("data", [])
	if data.is_empty():
		queue_banner(plaintext.replace("[", "[lb]"))
		return
	queue_banner(printjson_bbcode(data))

#endregion MESSAGE BANNER


#region TRANSLATIONS

func add_translations() -> void :
	var t := Translation.new()
	t.locale = TranslationServer.get_locale()
	t.add_message(&"UNLOCK_T_ap", "AP Item:")
	t.add_message(&"UNLOCK_ap_keys", "Keys")
	t.add_message(&"UNLOCK_ap_tiles", "Breakable Tiles")
	t.add_message(&"UNLOCK_ap_stop", "Stop Markers")
	t.add_message(&"UNLOCK_ap_go", "Go Markers")
	t.add_message(&"UNLOCK_ap_jump", "Jump Pads")
	t.add_message(&"UNLOCK_ap_switch", "Switch Tiles")
	t.add_message(&"UNLOCK_ap_dog", "Dog")
	t.add_message(&"UNLOCK_ap_portal", "Portals")
	t.add_message(&"UNLOCK_ap_nuke", "Nuke")
	t.add_message(&"UNLOCK_ap_golf", "Golf Balls")
	t.add_message(&"UNLOCK_ap_mine", "Landmines")
	t.add_message(&"UNLOCK_ap_metronome", "Metronome")
	t.add_message(&"UNLOCK_D_ap", "This item was obtained from Archipelago and can now be used!")
	TranslationServer.add_translation(t)

#endregion TRANSLATIONS
