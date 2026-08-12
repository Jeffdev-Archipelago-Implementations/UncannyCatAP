extends MinigameScene
class_name BartGame

var BART: = preload("uid://bukgtrpy8jinv")

signal round_changed(value: int)

@onready var timer_text: = $HUD / Timer as Label
@onready var round_text: = $HUD / Round as Label
@onready var barts_text: = $HUD / BartsLeft as Label
@onready var score_text: = $HUD / Score as Label

var game_active: = false
var winmode: = false

var round: = 0:
	set(value):
		round = value
		round_changed.emit(value)
var score: = 0
var bart_spawn_number: = 0
var barts_left: = 0

@onready var timer: Timer = $Timer

func _ready():

	score_text.text = "Score: " + str(score)
	timer.timeout.connect(time_over)

func _physics_process(delta):
	timer_text.text = str(int(ceil(timer.time_left)))

func start_game():
	game_active = true
	$clickallbarts.visible = false
	$music.play()
	next_round()

func next_round():
	if !game_active:
		return
	round += 1
	round_text.text = "ROUND " + str(round)
	bart_spawn_number = round * 5
	for i in range(0, bart_spawn_number):
		var newBart: = BART.instantiate() as Bart
		var speed = randi_range(100 + round * 30, 600 + round * 30)
		newBart.velocity = speed * (Vector2.from_angle(randf_range(0.261, 1.309) + randi_range(0, 3) * PI * 0.5))
		newBart.global_position = Vector2(randi_range(320, 704), randi_range(128, 448))
		newBart.die.connect(bart_kill)
		$Objects.add_child(newBart)
		barts_left += 1
	timer.paused = false
	timer.start()
	barts_text.text = "Borts Left: " + str(barts_left)

func bart_kill():
	barts_left -= 1
	barts_text.text = "Borts Left: " + str(barts_left)
	score += 50
	score_text.text = "Score: " + str(score)
	if barts_left == 0:
		timer.paused = true
		score += int(ceil(timer.time_left)) * 100
		score_text.text = "Score: " + str(score)
		$congrats.play()
		await $congrats.finished
		next_round()

func time_over():
	game_active = false
	$music.stop()
	for i in $Objects.get_children():
		i.queue_free()
	$lose.play()
	var final_rank: = clampi(score / 15000, 0, 6)
	$GameOver / Sprite2D.frame = final_rank
	$GameOver.visible = true

func _on_start_button_pressed() -> void :
	start_game()

func _on_exit_button_pressed() -> void :
	switch.emit(BartBash.GameScenes.GAME)
