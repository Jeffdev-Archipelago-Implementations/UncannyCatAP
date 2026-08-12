@tool
extends Node2D
class_name Level

var test_mode: = true

enum MODES{
	NORMAL, 
	ENDLESS, 
	DEMO
}

enum DEATH_TYPES{
	NORMAL = 0, 
	O_B = 1, 
	BACKROOMS = 2, 
	WALL_STUCK = 3, 
	HORSE = 4, 
	WATER = 5
}

signal tv_thought
signal pause
signal progress
signal died(type: DEATH_TYPES, cause: Node2D)

const OB_RADIUS = 24


@export var hideScoring: bool = false


@export var ID: String
@export var lvl_author: String
@export var music: Master.Music

@export var bounds: = 256:
	set(value):
		bounds = value
		queue_redraw()
@export var level_shade: Color = Color(1, 1, 1, 1)
@export var always_O_B: bool = false
@export var never_O_B: bool = false
@export var mirror_level: bool = false
@export var final_ghost_level: bool = false
@export var metronome_level: bool = false
@export var unskippable: bool = false
@export var resets_to_remind: int = 20

@export var par: int
@export var on_time: float

enum Ranks{UNCANNY, ATROCIOUS, STINKY, OK, SWAG, PEAK, RANK_COUNT}

@export var rank_reqs: Array[int] = [
	0, 
	1, 
	4500, 
	5500, 
	6000, 
	7500, 
]


@export var unlock_on_skip: bool = false


@export var unlocks: Array[StringName] = []


@export var peak_unlocks: Array[StringName] = []


@export var endless_blacklisted_mods: Array[String] = []

@export var results_no_progress: bool = false

@export var HUD: LevelHUD
@export var camera: Camera2D
@export var player: Player
@export var uncannies: Node2D
@export var switch_tiles: Array[TileMapLayer]
@export var win_confetti: AnimatedSprite2D

var mode: MODES = MODES.NORMAL
var loaded_demo: AttractData

var level_active: = false
var victory: = false
var lose: = false

var mod_data: Modifiers = Modifiers.new()

const SKIPCOUNT = 30
var skipcounter: = 0

var dblock_multiplier: = 0
var coin_multiplier: = 0
var switchState: = 0
signal switched

var strokes: = 0:
	set(new_value):
		if strokes > par and HUD.strokes_modulate > 0:
			HUD.strokes_modulate = 0.5 - 0.05 * (strokes - par)
		HUD.strokes.text = "[rainbow freq=" + str(HUD.strokes_modulate) + " sat=" + str(HUD.strokes_modulate) + " val=1.0]" + tr("GAME_Strokes").format({"stroke": str(new_value)})
		strokes = new_value
var time_elapsed: = 0.0

var stroke_bonus: = 0
var time_bonus: = 0
var level_bonus: = 0:
	set(new_value):
		HUD.levelB.text = tr("GAME_LevelBonus").format({"bonus": str(new_value)})
		level_bonus = new_value

var final_score: = 0

const MAX_BORTS = 30
var BORT: = preload("uid://bukgtrpy8jinv")
var borts: = 0
const BORT_TIME = 120
var bort_timer: = BORT_TIME

func _ready():
	if Engine.is_editor_hint():
		return
	if test_mode:
		get_tree().change_scene_to_file("res://assetsNEW/scenes/master.tscn")
		PThru.test_mode = true
		PThru.test_levelname = name
		PThru.test_level = load(scene_file_path)
		return

	if mode == MODES.NORMAL:
		LevelSelect.current_play_world = PThru.current.current_world_ID
		LevelSelect.current_play_level = PThru.current.current_level_ID

	HUD.visible = true
	switch()
	camera.zoom = Vector2(256.0 / bounds, 256.0 / bounds)
	if mirror_level:
		camera.zoom.x = - camera.zoom.x
	camera.position.x = -128 / camera.zoom.x
	var level_name = tr("GAME_Level" + ID)
	HUD.lvlName.text = ID + ": " + "" + level_name
	HUD.lvlAuthor.text = "Level by: " + lvl_author
	HUD.nameAnim.play("stagenameslide")
	HUD.strokes.text = "[rainbow freq=" + str(HUD.strokes_modulate) + " sat=" + str(HUD.strokes_modulate) + " val=1.0]" + tr("GAME_Strokes").format({"stroke": str(strokes)})
	HUD.levelB.text = tr("GAME_LevelBonus").format({"bonus": str(level_bonus)})
	if win_confetti != null:
		win_confetti.visible = false
		win_confetti.scale = Vector2(bounds / 256.0, bounds / 256.0)
	HUD.par.text = str(par)
	if mode == MODES.NORMAL and !test_mode and mod_data.mods["buddy"]:
		var buddy = load("uid://cmcwv7k1ov0ln").instantiate() as LittleBuddy
		buddy.player = player
		buddy.global_position = player.global_position
		add_child(buddy)
	if (mode == MODES.NORMAL or mode == MODES.ENDLESS) and !test_mode and mod_data.mods["missiles"]:
		var attacker: = load("uid://qk5gw874w6vh").instantiate() as MissileAttacker
		attacker.level = self
		attacker.player = player
		attacker.global_position = player.global_position
		add_child(attacker)
	if (mode == MODES.NORMAL or mode == MODES.ENDLESS) and !test_mode and mod_data.mods["E-bort"]:
		for i in 25:
			bort_spawn()
	if (mode == MODES.NORMAL or mode == MODES.ENDLESS) and !test_mode and mod_data.mods["E-bees"]:
		for i in 20:
			var bee: = load("uid://dle0ue7p82122").instantiate() as Bee

			bee.global_position = Vector2(randf_range(0, 768), randf_range(0, 512))
			HUD.add_child(bee)
			if i == 0:
				bee.buzz()
	if !test_mode:
		Master.thought_displayer.play_thought("Idle")
		Master.thought_displayer.autoplay_fallback = true
		Master.thought_displayer.fallback_category = "Idle"
	if PThru.current != null:
		if PThru.current.current_world_ID < Master.game_data.current_pthru.furthest_world_ID:
			return
		if PThru.current.current_level_ID == Master.game_data.current_pthru.furthest_level_ID:
			if !unskippable and PThru.current.times_reset == resets_to_remind:
				player.say("GAME_SkipRemind")

func _process(delta):
	if Engine.is_editor_hint():
		return

	if level_active:
		time_elapsed += delta
		HUD.time.text = Utils.format_seconds(time_elapsed)
		HUD.timeMil.text = Utils.format_seconds_mil(time_elapsed)
		if time_elapsed > on_time + 25:
			HUD.time.modulate = Color(1, 0, 0, 1)
		elif time_elapsed >= on_time:
			HUD.time.modulate = Color(1, 1, 0, 1)
		else:
			HUD.time.modulate = Color(0, 1, 0, 1)
		HUD.timeMil.modulate = HUD.time.modulate

func _physics_process(delta):
	if Engine.is_editor_hint():
		return

	if (mode == MODES.NORMAL) and !test_mode and mod_data.mods["god"] and Input.is_action_just_pressed(&"Teleport"):
		player.global_position = get_global_mouse_position()

	if mode != MODES.DEMO and Input.is_action_just_pressed(&"Click"):
		if lose:
			progress.emit(PThru.LEVEL_TRANSITION.RESET)
		elif mode == MODES.NORMAL and !level_active and victory:
			match HUD.resultsAnim.current_animation:
				"ResultsSlideDown":
					if !hideScoring:
						HUD.resultsAnim.play("ResultsAppear")
				"ResultsAppear":
					if !hideScoring:
						HUD.resultsAnim.play("ResultsRank")
				"":
					if results_no_progress:
						HUD.hide_scoring()
						HUD.hide_results()
						progress.emit(PThru.LEVEL_TRANSITION.GOLDEN_TEE)
						return
					if PThru.current != null:
						if PThru.current.peak_hunter and HUD.rank_calc != 5 and not hideScoring:
							progress.emit(PThru.LEVEL_TRANSITION.WIN_RESET)
						else:
							progress.emit(PThru.LEVEL_TRANSITION.NORMAL)
					else:
						progress.emit(PThru.LEVEL_TRANSITION.NORMAL)

	if mode != MODES.DEMO and Input.is_action_just_pressed(&"Restart"):
		if mode == MODES.NORMAL and victory:
			progress.emit(PThru.LEVEL_TRANSITION.WIN_RESET)
		elif level_active or lose:
			progress.emit(PThru.LEVEL_TRANSITION.RESET)

	if mode != MODES.DEMO and level_active and Input.is_action_just_pressed(&"Pause"):
		pause.emit()

	if mode != MODES.DEMO and (level_active or lose) and !unskippable:
		if Input.is_action_pressed(&"Skip"):
			if !test_mode:
				Master.thought_displayer.play_thought("Idle")
			skipcounter += 1
			if skipcounter > SKIPCOUNT:
				progress.emit(PThru.LEVEL_TRANSITION.SKIP)
		else:
			skipcounter = 0
	if !never_O_B:
		if level_active and max(abs(player.global_position.x), abs(player.global_position.y)) > (bounds + OB_RADIUS):
			if player.state == player.get_node("States/PJump") or always_O_B or player.jump_death_buffer > 0:
				death(DEATH_TYPES.O_B)
			else:
				death(DEATH_TYPES.BACKROOMS)









func _draw() -> void :
	if Engine.is_editor_hint():
		draw_rect(Rect2( - bounds, - bounds, bounds * 2, bounds * 2), Color.TOMATO, false, 4.0)


func switch():
	for i in switch_tiles.size():
		switch_tiles[i].enabled = (i == switchState)
	switched.emit()

func death(type: DEATH_TYPES, cause: Node2D = null):
	level_active = false
	lose = true
	died.emit(type, cause)
	player.transition_to("PLose", int(type == DEATH_TYPES.O_B))
	HUD.death(type)
	player.sprite.visible = false
	match type:
		DEATH_TYPES.WALL_STUCK:
			player.wall_explosion.play()
			player.wall_explosion.visible = true
			player.sfxWallDeath.play()
			if !test_mode:
				Master.thought_displayer.play_thought("Death")
				Master.thought_displayer.fallback_category = "Death"
		DEATH_TYPES.WATER:
			player.sfxWaterDeath.play()
			if !test_mode:
				Master.thought_displayer.play_thought("Death")
				Master.thought_displayer.fallback_category = "Death"
		DEATH_TYPES.BACKROOMS:
			if !test_mode:
				get_parent().play_music.emit(Master.Music.NONE, 1.0)
				Master.thought_displayer.play_thought("Backrooms")
				Master.thought_displayer.fallback_category = "Backrooms"
				pass
		_:
			if cause != null:
				HUD.jumpscare.modulate = cause.modulate
			if !test_mode:
				Master.thought_displayer.play_thought("Death")
				Master.thought_displayer.fallback_category = "Death"

func export_data():
	var data = LevelData.new()
	data.level_ID = ID
	data.highscore = final_score
	data.besttime = time_elapsed

	return data

func win():
	level_active = false
	victory = true
	if uncannies != null:
		for i in uncannies.get_children():
			i.queue_free()
	else:
		for i in get_children():
			if i is Ghost:
				i.queue_free()
	player.transition_to("PWin")
	HUD.skipping.visible = false
	if win_confetti != null:
		win_confetti.play()
		win_confetti.visible = true
	if !test_mode:
		Master.thought_displayer.play_thought("Win")
		Master.thought_displayer.fallback_category = "Win"

	if mode != MODES.DEMO:
		stroke_bonus = maxi(5000 + 500 * (par - strokes), 0)
		if strokes > 1:
			HUD.tStrokes.text = tr("GAME_Strokes").format({"stroke": str(strokes)})
		else:
			HUD.tStrokes2.modulate = Color(0, 1, 1, 1)
			HUD.tStrokes.text = tr("GAME_ResultStrokes1") if (strokes == 1) else tr("GAME_ResultStrokes0")
		match (int(strokes > par) - int(strokes < par)):
			-1:
				HUD.tStrokes2.modulate = Color(0, 1, 0, 1)
				HUD.tStrokes2.text = tr("GAME_ResultStrokesBelow4+").format({"stroke": str(par - strokes)}) + "\n" + tr("GAME_ResultBonus").format({"bonus": str(stroke_bonus)})
			0:
				HUD.tStrokes2.modulate = Color(0, 1, 0, 1)
				HUD.tStrokes2.text = tr("GAME_ResultStrokesEven") + "\n" + tr("GAME_ResultBonus").format({"bonus": str(stroke_bonus)})
			1:
				HUD.tStrokes2.modulate = Color(1, 0.2, 0, 1)
				HUD.tStrokes2.text = tr("GAME_ResultStrokesAbove4+").format({"stroke": str(strokes - par)}) + "\n" + tr("GAME_ResultBonus").format({"bonus": str(stroke_bonus)})
		time_bonus = maxi(2500 - 100 * (time_elapsed - on_time), 0)
		HUD.tTime.text = tr("GAME_Time").format({"time": Utils.format_seconds(time_elapsed) + Utils.format_seconds_mil(time_elapsed)})
		if time_elapsed >= on_time:
			var tardy: = int(time_elapsed - on_time)
			if tardy < 1:
				HUD.tTime2.modulate = Color.YELLOW
				HUD.tTime2.text = tr("GAME_ResultBarelyLate") + "\n" + tr("GAME_ResultBonus").format({"bonus": str(time_bonus)})
			else:
				HUD.tTime2.modulate = Color(1, 0.2, 0, 1)
				HUD.tTime2.text = tr("GAME_ResultLate").format({"sec": str(tardy)}) + "\n" + tr("GAME_ResultBonus").format({"bonus": str(time_bonus)})
		else:
			HUD.tTime2.modulate = Color(0, 1, 0, 1)
			HUD.tTime2.text = tr("GAME_ResultOnTime") + "\n" + tr("GAME_ResultBonus").format({"bonus": str(time_bonus)})

		HUD.tBonus.text = tr("GAME_LevelBonus").format({"bonus": str(level_bonus)})
		final_score = stroke_bonus + time_bonus + level_bonus
		HUD.fill.max_value = rank_reqs[Ranks.PEAK]




		if mode == MODES.NORMAL:
			HUD.resultsAnim.play("ResultsSlideDown")
		elif mode == MODES.ENDLESS:
			progress.emit(Endless.LEVEL_TRANSITION.NORMAL)
		else:
			pass
	else:
		HUD.get_node("Sounds/win").play()

func bort_spawn():
	var newBort: = BORT.instantiate() as Bart
	var speed = randi_range(100, 700)
	newBort.velocity = speed * (Vector2.from_angle(randf_range(0.261, 1.309) + randi_range(0, 3) * PI * 0.5))
	newBort.global_position = Vector2(randi_range(320, 704), randi_range(64, 448))
	newBort.die.connect(bort_kill)
	HUD.add_child(newBort)
	borts += 1

func bort_kill():
	level_bonus += 100
	borts -= 1
