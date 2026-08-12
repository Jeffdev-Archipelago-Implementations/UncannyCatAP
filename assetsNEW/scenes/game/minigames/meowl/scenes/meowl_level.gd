extends MinigameScene
class_name MeowlLevel

enum Enemies{
	MEOWLCAHOLIC = 0, 
	MEOWFFICER = 1, 
	MEOWLTHHEAD = 2, 
	EGG = 3, 
	MEOWLIGATOR = 4
}

var WORLDS: Array[CompressedTexture2D] = [
	load("uid://d4mpf28snbo2l"), 
	load("uid://rpwc7an0rysx"), 
	load("uid://dm13lpy4s4mdu"), 
	load("uid://bwcdbd1naqjlr"), 
	load("uid://c0i0v71exuhp5"), 
	load("uid://c7mrng4ka1qe0"), 
	load("uid://dww8y20un56s1"), 
	load("uid://dkdn2bun5dy6g"), 
	load("uid://4inetuaoltl"), 
	load("uid://cn3re65dfryqb"), 
	load("uid://t4sb20obya2j"), 
	load("uid://d0163gaxnqhrc"), 
	load("uid://dcrkn0qw7pwnh")
]

var difficulty_settings: Array[Array] = [
	[200, 0, 0, 0, 0], 
	[200, 425, 0, 0, 0], 
	[110, 325, 0, 0, 0], 
	[154, 525, 0, 0, 500], 
	[0, 0, 80, 0, 0], 
	[220, 522, 150, 0, 0], 
	[222, 0, 0, 400, 0], 
	[0, 100, 633, 0, 0], 
	[0, 0, 0, 180, 0], 
	[777, 0, 150, 350, 0], 
	[200, 800, 0, 300, 500], 
	[30, 0, 0, 0, 0], 
	[0, 0, 0, 120, 300], 
	[300, 300, 300, 300, 300], 
	[1000, 0, 50, 0, 0], 
	[100, 100, 0, 0, 0], 
	[0, 0, 0, 60, 1000], 
	[0, 0, 166, 0, 100], 
	[30, 0, 0, 300, 0], 
	[0, 50, 0, 0, 0], 
	[50, 110, 170, 230, 290], 
	[200, 200, 200, 200, 200], 
	[0, 150, 100, 0, 0], 
	[80, 100, 0, 0, 0], 
	[20, 0, 0, 0, 0], 
	[200, 0, 0, 0, 0], 
	[300, 300, 300, 300, 300], 
	[1000, 0, 50, 0, 0], 
	[100, 100, 0, 0, 0], 
	[0, 0, 0, 60, 1000], 
	[0, 0, 166, 0, 100], 
	[30, 0, 0, 300, 0], 
	[0, 50, 0, 0, 0], 
	[50, 110, 170, 230, 290], 
	[200, 200, 200, 200, 200], 
	[0, 150, 100, 0, 0], 
	[80, 100, 0, 0, 0], 
	[20, 0, 0, 0, 0], 
	[200, 0, 0, 0, 0], 
	[400, 0, 1100, 0, 0], 
	[1100, 0, 300, 0, 0], 
	[0, 0, 300, 0, 0], 
	[0, 0, 600, 0, 0], 
	[0, 0, 900, 0, 0], 
	[0, 0, 1200, 0, 0], 
	[0, 0, 1500, 0, 0], 
]

@export var player: PlayerMeowl
@export var hazard_folder: Node2D

@onready var health_bar: = $GameHUD / Fill as TextureProgressBar
@onready var distance_text: = $GameHUD / DistanceText as Label
@onready var world_bg: = $BG / Layer2 / WorldBG as Sprite2D
@onready var world_bg2: = $BG / Layer2 / WorldBG2 as Sprite2D
@onready var world_name_anim: = $GameHUD / WorldNameAnim as AnimationPlayer
@onready var tree: = $Hazards / TreeHazard as TreeHazard

signal score_changed(value: int)

const WORLD_RATE: = 15000

var ENEMY1_TIME: = 0
var enemy1_timer: = 0
var ENEMY2_TIME: = 0
var enemy2_timer: = 0
var ENEMY3_TIME: = 0
var enemy3_timer: = 0
var ENEMY4_TIME: = 0
var enemy4_timer: = 0
var ENEMY5_TIME: = 0
var enemy5_timer: = 0

var game_active: = false
var score: = 0:
	set(value):
		distance_text.text = str(value)
		score = value
		score_changed.emit(value)
var score_to_next: = WORLD_RATE
var difficulty: = 0
var laps: = 0

func _ready() -> void :
	player.game_start.connect(start)
	player.died.connect(death)
	health_bar.value = player.health
	ENEMY1_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWLCAHOLIC]
	ENEMY2_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWFFICER]
	ENEMY3_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWLTHHEAD]
	ENEMY4_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.EGG]
	ENEMY5_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWLIGATOR]

func _physics_process(delta: float) -> void :
	if game_active:
		if ENEMY1_TIME != 0:
			if enemy1_timer > ENEMY1_TIME:
				var e: Meowlcaholic = Meowlcaholic.initialize(Vector2(792, randf_range(96.0, 416.0)), 3.0, 5.0)
				hazard_folder.add_child.call_deferred(e)
				enemy1_timer = 0
			enemy1_timer += 1
		if ENEMY2_TIME != 0:
			if enemy2_timer > ENEMY2_TIME:
				var e: Meowfficer = Meowfficer.initialize(Vector2(792, randf_range(96.0, 416.0)), 1.0, 2.0, self, player)
				hazard_folder.add_child.call_deferred(e)
				enemy2_timer = 0
			enemy2_timer += 1
		if ENEMY3_TIME != 0:
			if enemy3_timer > ENEMY3_TIME:
				var e: Meowlthhead = Meowlthhead.initialize(randf_range(96.0, 416.0), tree)
				hazard_folder.add_child.call_deferred(e)
				enemy3_timer = 0
			enemy3_timer += 1
		if ENEMY4_TIME != 0:
			if enemy4_timer > ENEMY4_TIME:
				var e: MeowlEgg = MeowlEgg.initialize(Vector2.ZERO, self, player)
				hazard_folder.add_child.call_deferred(e)
				enemy4_timer = 0
			enemy4_timer += 1
		if ENEMY5_TIME != 0:
			if enemy5_timer > ENEMY5_TIME:
				var e: Meowligator = Meowligator.initialize(Vector2(832, 512), 1.5)
				hazard_folder.add_child.call_deferred(e)
				enemy5_timer = 0
			enemy5_timer += 1
		$music.pitch_scale += 5e-06
		health_bar.value = player.health
		score += 5


		if score >= score_to_next - 200:
			world_bg.material.set("shader_parameter/light", move_toward(world_bg.material.get("shader_parameter/light"), 1.0, 0.04))
		else:
			world_bg.material.set("shader_parameter/light", move_toward(world_bg.material.get("shader_parameter/light"), 0.0, 0.04))
		if score >= score_to_next:
			next_stage()

func start() -> void :
	$BG / Layer2.autoscroll = Vector2(-20, 0)
	$BG / IntroScroll.play(&"Scroll")
	$music.play()
	game_active = true

func next_stage() -> void :
	difficulty += 1
	ENEMY1_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWLCAHOLIC]
	ENEMY2_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWFFICER]
	ENEMY3_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWLTHHEAD]
	ENEMY4_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.EGG]
	ENEMY5_TIME = difficulty_settings[clampi(difficulty, 0, difficulty_settings.size() - 1)][Enemies.MEOWLIGATOR]
	enemy1_timer = 0
	enemy2_timer = 0
	enemy3_timer = 0
	enemy4_timer = 0
	enemy5_timer = 0
	world_bg.texture = WORLDS[difficulty % WORLDS.size()]
	world_bg2.texture = world_bg.texture
	score_to_next = WORLD_RATE * (difficulty + 1)
	if difficulty % WORLDS.size() == 0:
		laps += 1
		$GameHUD / WorldName.text = tr("MINIGAME_Meowl_StatusSpecial").format({"number": str(laps)})
		if laps == 1:
			$GameHUD / PhoneNumber.play(&"PhoneAppear")
	else:
		$GameHUD / WorldName.text = tr("MINIGAME_Meowl_Status")
	if difficulty >= 39:
		player.weary = true
	world_name_anim.play(&"RESET")
	world_name_anim.play(&"WorldNameSlide")

func death() -> void :
	switch.emit(MeowlGame.GameScenes.DEATH, score)
