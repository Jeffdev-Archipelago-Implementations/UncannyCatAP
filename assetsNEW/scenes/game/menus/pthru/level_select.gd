extends Menu
class_name LevelSelect

const LEVEL_BUTTON = preload("res://assetsNEW/scenes/menu_objects/buttons/level_select_button.tscn")
var CURRENT_PTHRU: = Master.game_data.current_pthru

@export var world_sprites: Array[Sprite2D]
@export var world_BGs: Array[Node2D]

@onready var pthru_HUD: = $PthruHUD as PthruHUD
@onready var world_header: = $WorldHeader as Label
@onready var selected_name: = $SelectedName as Label
@onready var selected_stats: = $SelectedStats as Label
@onready var selected_rank: = $SelectedRank as Sprite2D

@onready var map_layer: = $MapLayer as CanvasLayer
@onready var map_points: = $MapLayer / WorldPoints as Node2D

@onready var scroll_container: Control = $Control

static var current_play_world: = -1
static var current_play_level: = -1


var looking_at_world: = 0

var selected_ID: int

func _ready() -> void :
	play_music.emit(music)
	pthru_HUD.tscore_text.text = " [wave]" + str(Master.game_data.current_pthru.total_score) + " !"
	pthru_HUD.tprism_text.text = str(Master.game_data.current_pthru.total_prisms)
	pthru_HUD.resets_text.text = str(Master.game_data.current_pthru.total_resets)
	pthru_HUD.ttime_text.text = Utils.format_seconds_speedrun(Master.game_data.current_pthru.total_time)

	if current_play_world >= 0 and current_play_level >= 0:
		looking_at_world = current_play_world
	else:
		looking_at_world = mini(CURRENT_PTHRU.furthest_world_ID, 5)
		# if CURRENT_PTHRU.modifiers.mods["easy_mode"]:
		# 	looking_at_world = mini(looking_at_world, 4)

	$WorldPrev.disabled = looking_at_world <= 0
	## Adjusting to make the max limit 7, from AP mod
	$WorldNext.disabled = looking_at_world >= mini(CURRENT_PTHRU.furthest_world_ID, 7)
	if looking_at_world == 6:
		if CURRENT_PTHRU.furthest_level_ID == 0:
			$WorldHeader.text = "?"
		else:
			$WorldHeader.text = tr("GAME_WorldP")
	# AP Mod Code to show Endless Levels properly, just shows a raw string cause im lazy - Jeff
	elif looking_at_world == 7:
		$WorldHeader.text = "ENDLESS LEVELS"
	else:
		$WorldHeader.text = tr("GAME_World" + str(looking_at_world))
	var all_worlds: = Master.game_data.worlds
	for world in range(0, all_worlds.size()):
		var max_world = CURRENT_PTHRU.furthest_world_ID
		# if CURRENT_PTHRU.modifiers.mods["easy_mode"]:
		# 	max_world = mini(max_world, 4)
		if world > max_world:
			for level in range(0, all_worlds[world].total_levels()):
				add_new_button(world, level, false, true)
		else:
			for level in range(0, all_worlds[world].total_levels()):
				if world == CURRENT_PTHRU.furthest_world_ID and level > CURRENT_PTHRU.furthest_level_ID:

					add_new_button(world, level, false, true)
				else:
					add_new_button(world, level, false, false, current_play_world == world and current_play_level == level)


	current_play_world = -1
	current_play_level = -1
	await get_tree().process_frame
	get_parent().update_mods(Master.game_data.current_pthru.modifiers)

func _exit_tree() -> void :

	get_parent().update_mods(Modifiers.new())
	current_play_world = -1
	current_play_level = -1

func _physics_process(delta: float) -> void :
	var target_pos: = Vector2(0, - scroll_container.size.y * looking_at_world)
	button_group.position = button_group.position.lerp(target_pos, 0.15)

	var map_pos: Vector2 = map_points.get_children()[looking_at_world].position
	map_layer.offset = map_layer.offset.lerp( - map_pos, 0.15)
	for i in range(0, world_sprites.size()):
		if i == looking_at_world:
			world_sprites[i].modulate.a = lerp(world_sprites[i].modulate.a, 1.0, 0.15)
		else:
			if i <= Master.game_data.current_pthru.furthest_world_ID:
				world_sprites[i].modulate.a = lerp(world_sprites[i].modulate.a, 0.5, 0.15)
			else:
				world_sprites[i].modulate = Color.BLACK

	for i in range(0, world_BGs.size()):
		var bg = world_BGs[i]
		if i == looking_at_world:
			bg.modulate.a = lerp(bg.modulate.a, 0.8, 0.15)
		else:
			bg.modulate.a = lerp(bg.modulate.a, 0.0, 0.15)

func add_new_button(world_ID: int, level_ID: int, bonus_lvl: bool, locked: bool = false, autoselect: bool = false):
	var level_butt: LevelSelectButton = LEVEL_BUTTON.instantiate()
	var all_bonus_datas: = CURRENT_PTHRU.bonus_level_datas
	level_butt.position = Vector2(16, 16 + world_ID * scroll_container.size.y)
	level_butt.position.x += (level_ID % 3) * 72
	level_butt.position.y += (level_ID / 3) * 72
	if locked:
		level_butt.set_lock(locked)
	else:
		var prisms: Array[PrismVisual]
		for c: PrismVisual in level_butt.prisms.get_children():
			prisms.append(c as PrismVisual)
		if bonus_lvl:
			assert (false, "Bonus Level no function right now. Go away fuckkin biiiitch")
		else:
			if world_ID == 6:
				level_butt.level_num.text = "%s-%d" % ["P", level_ID + 1]
			elif world_ID == 7:
				level_butt.level_num.text = "%s-%d" % ["E", level_ID]
			else:
				level_butt.level_num.text = "%d-%d" % [world_ID, level_ID + 1]
			level_butt.ID = "%d-%d" % [world_ID, level_ID + 1]

			var level_data = CURRENT_PTHRU.get_level(world_ID, level_ID)

			var prism_count: = 0
			for i in prisms.size():
				if i + 1 <= level_data.rank:
					prisms[i].set_deferred(&"collected", true)
					prism_count += 1
			if prism_count == 5:
				level_butt.mark_peaked()

		level_butt.pressed.connect(level_selected.bind(level_butt.ID, level_butt.level_num.text))
	button_group.add_child(level_butt)
	if autoselect:
		level_butt.grab_focus.call_deferred()
		level_selected.call_deferred(level_butt.ID, level_butt.level_num.text)

func level_selected(ID: String, name_ID: String):
	$LevelStart.disabled = false
	var split_ID = ID.split("-")
	if split_ID[0] == "E":
		split_ID[0] = "7"
	if int(split_ID[0]) != looking_at_world:
		return
	var world_id: int = split_ID[0].to_int()
	var level_id: int = split_ID[1].to_int()
	var level_data = CURRENT_PTHRU.get_level(world_id, level_id - 1)
	selected_ID = split_ID[0].to_int() * 1000 + (split_ID[1].to_int() - 1)
	selected_name.text = name_ID + "\n" + tr("GAME_Level" + name_ID)
	if level_data != null:
		if level_data.best_time == INF:
			selected_stats.text = "Best Score: " + str(level_data.best_score) + "\nBest Time: --:--.--"
		else:
			selected_stats.text = "Best Score: " + str(level_data.best_score) + "\nBest Time: " + str(Utils.format_seconds(level_data.best_time) + Utils.format_seconds_mil(level_data.best_time))
		selected_rank.frame = level_data.rank
	else:
		selected_stats.text = "Best Score: 0\nBest Time: --:--.--"
		selected_rank.frame = 0

func _on_level_start_pressed() -> void :
	if selected_ID != null:
		switch.emit(Master.GameScenes.PTHRU_MANAGER, selected_ID)
	else:
		push_error("This level isn't real! Go fuck yourself!")

func _on_control_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_button_event: = event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_look_at_world(looking_at_world - 1)
		elif mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_look_at_world(looking_at_world + 1)

func _on_world_prev_pressed() -> void :
	_look_at_world(looking_at_world - 1)

func _on_world_next_pressed() -> void :
	_look_at_world(looking_at_world + 1)

func _look_at_world(world: int) -> void :
	## Adjusting to make the max limit 7, from AP mod
	var max_world = 7
	looking_at_world = clampi(world, 0, mini(CURRENT_PTHRU.furthest_world_ID, max_world))
	$WorldPrev.disabled = looking_at_world <= 0
	$WorldNext.disabled = looking_at_world >= mini(CURRENT_PTHRU.furthest_world_ID, max_world)
	if looking_at_world == 6:
		if CURRENT_PTHRU.furthest_level_ID == 0:
			$WorldHeader.text = "?"
		else:
			$WorldHeader.text = tr("GAME_WorldP")
	# AP Mod Code to show Endless Levels properly, just shows a raw string cause im lazy - Jeff
	elif looking_at_world == 7:
		$WorldHeader.text = "ENDLESS LEVELS"
	else:
		$WorldHeader.text = tr("GAME_World" + str(looking_at_world))
