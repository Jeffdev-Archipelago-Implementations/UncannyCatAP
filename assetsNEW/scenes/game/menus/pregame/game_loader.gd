extends GameScene
class_name GameLoader

signal material_preload_finished()

const LEVEL_PATH = "res://assetsNEW/scenes/game/levels/regular"

@export_dir var materials_dir: String
@export var material_spinner: Node2D

@onready var anims: = $AnimationPlayer as AnimationPlayer

var progress: = 0
var anim_mode: = false

var thread_worlds: Thread = Thread.new()

var materials_loaded: = false

func _ready() -> void :
	Utils.update_unlocked_skins()
	if Settings.load_settings():
		Master.current.restore_presents()
		initialize_settings()
		on_overlay_return()
	else:
		overlay.emit(Master.GameScenes.START_CRACKTRO)

func _physics_process(delta: float) -> void :
	if anim_mode == true and Input.is_action_just_pressed("Click"):
		if !PThru.test_mode:
			switch.emit(Master.GameScenes.TITLE)
		else:
			switch.emit(Master.GameScenes.PTHRU_MANAGER, 4017)


func load_worlds(DIR: String, worlds_to_load: PackedStringArray, destination: Array[World]):
	material_spinner.hide.call_deferred()

	Master.game_data.worlds.resize(worlds_to_load.size())
	for i in worlds_to_load.size():
		var new_world: = World.new()
		var w_id: = worlds_to_load[i]
		new_world.world_ID = w_id
		new_world.world_name = "GAME_World" + new_world.world_ID
		var path: = DIR.path_join("w" + new_world.world_ID)
		if new_world.world_ID == "7":
			path = "res://assetsNEW/scenes/game/levels/endless"

		if not PThru.test_mode:
			new_world.load_world(path)
		Master.game_data.worlds[i] = new_world

	await Master.current.load_scenes()
	return call_deferred("load_complete")

func dispatch_load_world(DIR: String, worlds_to_load: PackedStringArray, destination: Array[World], index: int):

	load_world(DIR, worlds_to_load[index], index)



func load_world(DIR: String, W_ID: String, index: int, SCENE_EXT: String = ".tscn"):
	var new_world: World = World.new()
	new_world.world_ID = W_ID
	new_world.world_name = "GAME_World" + W_ID
	var dir_path: = DIR + "/w" + W_ID
	var files: = ResourceLoader.list_directory(dir_path)
	var bonus_directory: DirAccess = DirAccess.open(dir_path + "/bonus")
	var bonus_path: = dir_path.path_join("bonus")
	if PThru.test_mode:
		for file in files:
			var t = false
			if file[2] == "0":
				t = true
			if t:
				if file.replace("0", "") == PThru.test_levelname.replacen("-", "_") + ".tscn":
					PThru.test_level = load(dir_path.path_join(file))
					break
			else:
				if file == PThru.test_levelname.replacen("-", "_") + ".tscn":
					PThru.test_level = load(dir_path.path_join(file))
					break
	else:
		for file in files:
			if file.ends_with(SCENE_EXT):
				var level: = load(dir_path.path_join(file)) as PackedScene
				var level_pos: int = file.split(".")[0].split("_")[1].to_int()


				if level_pos >= new_world.regular_levels.size():
					for i in (level_pos - 1) - new_world.regular_levels.size():
						new_world.regular_levels.append(null)
					new_world.regular_levels.append(level)
				else:
					new_world.regular_levels[level_pos - 1] = level
				progress += 1
	if bonus_directory != null:
		for file in ResourceLoader.list_directory(bonus_path):
			if file.ends_with(SCENE_EXT):
				var level: = load(bonus_path.path_join(file)) as PackedScene

				new_world.bonus_levels.append(level)
				progress += 1


	if index >= Master.game_data.worlds.size():
		for i in index - Master.game_data.worlds.size():
			Master.game_data.worlds.append(null)
		Master.game_data.worlds.append(new_world)
	else:
		Master.game_data.worlds[index] = new_world



func load_complete():
	$loading_sprite.visible = false



	anims.play(&"CoverFadeIn")




func preload_materials() -> void :
	for file in ResourceLoader.list_directory(materials_dir):
		await get_tree().process_frame
		%material_display.material_override = load(materials_dir.path_join(file))

	materials_loaded = true
	%material_sprite.visible = false
	material_preload_finished.emit()




func on_overlay_return(state: int = 0):
	await get_tree().process_frame
	$startup.play()
	if PThru.test_mode:
		$TestMode.visible = true
		$startup.pitch_scale = 1.5
	anims.play(&"CoverFadeOut")

func initialize_settings():
	pass

func _on_sweepsound_finished() -> void :
	if !PThru.test_mode:
		switch.emit(Master.GameScenes.TITLE)
	else:
		switch.emit(Master.GameScenes.PTHRU_MANAGER, 4017)

func _on_animation_player_animation_finished(anim_name: StringName) -> void :
	if anim_name == &"CoverFadeOut":
		$loading_sprite.visible = true
		thread_worlds.start(load_worlds.bind(LEVEL_PATH, ["0", "1", "2", "3", "4", "5", "6", "7"], Master.game_data.worlds))
	elif anim_name == &"CoverFadeIn":
		anims.play(&"DisclaimerFadeIn")
		anim_mode = true
