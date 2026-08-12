extends "res://assetsNEW/scenes/game/menus/title_screen.gd"

var ap_scene_id: = -1

func _ready() -> void:
	super._ready()

	var prompt := find_child("ClickPrompt") as Label
	if prompt:
		prompt.text = "Click to connect to Archipelago!"

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"Click"):
		if animator.current_animation == &"TitleAppear":
			%TitleHit.stop()
			%TitleImpact.play()
			animator.play(&"AllAppear")
		else:
			switch.emit(ap_scene_id if ap_scene_id != -1 else Master.GameScenes.MAIN_MENU)
			return
	if idle_timer > IDLE_TIME:
		switch.emit(Master.GameScenes.ATTRACT_DEMO)
		return
	else:
		idle_timer += 1
