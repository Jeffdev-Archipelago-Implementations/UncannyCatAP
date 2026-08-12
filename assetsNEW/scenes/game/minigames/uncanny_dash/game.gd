extends Node2D
class_name UncannyDashGame

signal score_changed(value: int)

const level_size = 24
const left_margin = 4
const level_position = Vector2(64, 64)
const tile_size = 8.0

var level = range(level_size)
var time_left = 4
var score = 0:
	set(value):
		score = value
		score_changed.emit(value)
var high_score = 0
var first_input: = true

@onready var timer = %Timer


func _ready() -> void :
	generate_level()
	first_input = false


func _physics_process(delta: float) -> void :
	if Input.is_action_just_pressed("Click") && get_parent().inactive == false:
		if !first_input:

			play_sound("uid://cmao1c56l8mii")
			%Player.position.x += 1
			%PlayerSprite.position.x = ( %Player.position.x * tile_size) + (left_margin * tile_size)
			add_score()

			if %Player.position.x > level_size - 1:
				next_level()
		else:
			first_input = false
	elif Input.is_action_just_pressed("RightClick") && get_parent().inactive == false:
		if !first_input:
			play_sound("uid://ma7jva6knxyf")
			%Player.position.x += 2
			%PlayerSprite.position.x = ( %Player.position.x * tile_size) + (left_margin * tile_size)
			add_score()

			if %Player.position.x > level_size - 1:
				next_level()
		else:
			first_input = false


	if %Player.position.x < level_size:
		if level[ %Player.position.x] == 0: die()

func add_score(amount = 1):
	score += amount
	var numbers = %Numbers
	var score_string = str(score)
	if score < 10:
		score_string = str("000") + score_string
	else:
		if score < 100:
			score_string = str("00") + score_string
		else:
			if score < 1000:
				score_string = str("0") + score_string

	numbers.set_cell(Vector2(60, 0), 0, Vector2(int(score_string.split()[0]), 0))
	numbers.set_cell(Vector2(61, 0), 0, Vector2(int(score_string.split()[1]), 0))
	numbers.set_cell(Vector2(62, 0), 0, Vector2(int(score_string.split()[2]), 0))
	numbers.set_cell(Vector2(63, 0), 0, Vector2(int(score_string.split()[3]), 0))
	set_highscore()

func set_highscore():
	if score > high_score: high_score = score
	var score_string = str(high_score)
	if high_score < 10:
		score_string = str("000") + score_string
	else:
		if high_score < 100:
			score_string = str("00") + score_string
		else:
			if high_score < 1000:
				score_string = str("0") + score_string
	%HighScoreNumbers.set_cell(Vector2(4, 0), 0, Vector2(int(score_string.split()[0]), 0))
	%HighScoreNumbers.set_cell(Vector2(5, 0), 0, Vector2(int(score_string.split()[1]), 0))
	%HighScoreNumbers.set_cell(Vector2(6, 0), 0, Vector2(int(score_string.split()[2]), 0))
	%HighScoreNumbers.set_cell(Vector2(7, 0), 0, Vector2(int(score_string.split()[3]), 0))




func next_level():
	if %Timer.wait_time > 3: %Timer.wait_time -= 0.5
	%Timer.start()
	%Time.size.x = 4
	%TimeCat.scale.x = 4
	time_left = 4
	add_score(10)
	%Player.position.x = 0
	%PlayerSprite.position.x = ( %Player.position.x * tile_size) + (left_margin * tile_size)
	generate_level()

func play_sound(stream):
	if ! %TimerSound.is_playing():
		%Sound.set_stream(load(stream))
		%Sound.play()

func die():
	get_owner().die()
	%Timer.stop()
	%Timer.set_wait_time(10)
	%Time.size.x = 4
	%TimeCat.scale.x = 4
	time_left = 4

	%Player.position.x = 0
	%PlayerSprite.position.x = ( %Player.position.x * tile_size) + (left_margin * tile_size)
	set_highscore()
	score = 0
	first_input = true





func generate_level():
	var tilemap = %LevelMap
	level[0] = 1
	level[level_size - 1] = 1

	for i in level_size:
		var r = randi_range(0, 1)

		if i > 1 && i < level_size - 1:

			if level[i - 1] == 0:
				level[i] = 1
			else:

				level[i] = r
		tilemap.set_cell(Vector2(i + left_margin, 0), 0, Vector2(level[i], i % 2))


func _on_timer_timeout() -> void :
	if get_parent().inactive == false:
		time_left -= 1
		%TimeCat.scale.x -= 1
		%Time.size.x -= 1
		%TimerSound.play()
		if time_left == 0: die()
