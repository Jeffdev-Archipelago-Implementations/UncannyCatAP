extends CharacterBody2D
class_name Player

var level: Level

@export var state: Node

@export var hit_dir: Line2D
@export var credits_mode: bool = false
@onready var sprite: = $Sprite2D
@onready var sweat: = $Sprite2D / Sweat
@onready var goggles: = $Sprite2D / Goggles
@onready var hitbox: = $CollisionShape2D
@onready var wall_explosion: = $WallExplosion


@onready var sfxJoin: = $Sounds / Join
@onready var sfxLaunched: AudioStreamPlayer = $Sounds / Launched
@onready var sfxLaunchedDizzy: AudioStreamPlayer = $Sounds / LaunchedDizzy
@onready var sfxBurst: = $Sounds / Burst
@onready var sfxWallBump: = $Sounds / WallBump
@onready var sfxPush: = $Sounds / Push
@onready var sfxGrab: = $Sounds / Grab
@onready var sfxGrabCancel: = $Sounds / GrabCancel
@onready var sfxPickUp: = $Sounds / PickUp
@onready var sfxWallDeath: = $Sounds / WallDeath
@onready var sfxWaterDeath: = $Sounds / WaterDeath
@onready var sfxWaterSplash: = $Sounds / WaterSplash
@onready var sfxParry: = $Sounds / Parry
@onready var sfxClink: = $Sounds / WallClink
@onready var speech_label: RichTextLabel = $Speech / SpeechLabel
@onready var speech_player: AnimationPlayer = $Speech / SpeechPlayer



const MAX_DRAG = 175
const DRAG_MULTIPLIER = 5
const DRAG_CANCEL = 20
const FRIC_COEFF = 0.04
const FRIC_POW = 1.06
const STOP_SPEED = 20
const JUMP_TIME = 26
const SHOT_BUFFER_FRAMES = 12

const HUE_WEAKEST = 0.69
const HUE_STRONGEST = 0

const WALL_DEATH_TIME = 10
const PARRY_ACTIVE = 33
const PARRY_WINDOW = 23
const PARRY_TIME = 16

const STICK_PITCH_MIN: = 0.8
const STICK_PITCH_MAX: = 1.0

const AFTERIMAGE_THRESHOLD_MIN: = 500.0
const AFTERIMAGE_THRESHOLD_MAX: = 900.0
const AFTERIMAGE_OPACITY: = 0.75
const AFTERIMAGE_FADE_TIME: = 0.15
const AFTERIMAGE_RATE: = 0.05

const LAUNCH_PITCH_MIN: = 0.9
const LAUNCH_PITCH_MAX: = 1.1
const LAUNCH_POWER_MIN: = DRAG_CANCEL * DRAG_MULTIPLIER
const LAUNCH_POWER_MAX: = MAX_DRAG * DRAG_MULTIPLIER


var click_pos: Vector2:
	set(v):
		click_pos = v
		if (get_global_mouse_position() - global_position).length_squared() < 256:
			clicked()
var buffered_shot: Vector2 = Vector2.ZERO
var buffered_shot_frame: int

var goal: Goal = null
var horsegoal: Node
var wall_death_count: = 0
var wall_death_timer: = 0
var portal_sick_timer: = 0
var portal_sick: = false
var jump_death_buffer: = 0


@export var additional_velocity: = Vector2(0, 0)
var truevel: = Vector2(0, 0)

var has_keys: Array[Key] = []
var key_rotation_offset: = Vector2(48.0, 0.0)
const KEY_ROTATE_SPEED = 2.5

var afterimage_cooldown: = 0.0


@export_flags_2d_physics var jump_collision_mask: int
@onready var normal_collision_mask: int = collision_mask


var pause_glass: = false
var glass_health: = 3

var parry_active: = 0
var parry_timer: = 0

var tk_strokes: float = 0.0:
	set(value):
		tk_strokes = value
		while tk_strokes >= 1.0:
			level.strokes += 1
			tk_strokes -= 1.0


func transition_to(target_state_name: String, type: int = 0):
	assert (has_node("States/" + target_state_name))
	state.exit()
	state = get_node("States/" + target_state_name)
	state.enter(type)
	state.update()

func _ready():
	sprite.texture = Master.costume.graphic
	sprite.material = Master.costume.material
	if level == null and owner is Level:
		level = owner
		sprite.modulate = level.level_shade
	state.enter()


func _physics_process(delta):
	if Input.is_action_just_pressed(&"Click"):
		buffered_shot_frame = 0
		click_pos = get_viewport().get_mouse_position()
	state.update()

	if not credits_mode and state != $States / PLose and state != $States / PWin:
		wall_death_timer += 1
		if wall_death_count >= WALL_DEATH_TIME - 1:
			level.death(Level.DEATH_TYPES.WALL_STUCK)
		if wall_death_timer > WALL_DEATH_TIME:
			wall_death_count = 0
			wall_death_timer = 0
			sfxWallBump.pitch_scale = 1.0

		if parry_active > 0:
			parry_active -= 1
		if mod_active("parry") and parry_active <= 0 and Input.is_action_just_pressed(&"RightClick"):
			parry_active = PARRY_ACTIVE
		if jump_death_buffer > 0:
			jump_death_buffer -= 1


	afterimage_cooldown -= delta
	if velocity.is_zero_approx():
		afterimage_cooldown = 0.0
	if afterimage_cooldown <= 0.0:
		afterimage_cooldown += AFTERIMAGE_RATE
		if velocity.length() >= AFTERIMAGE_THRESHOLD_MIN:
			var afterimage = Sprite2D.new()
			afterimage.texture = sprite.texture
			afterimage.material = sprite.material
			afterimage.global_position = sprite.global_position
			afterimage.global_scale = sprite.global_scale
			afterimage.z_index = -1
			var weight = inverse_lerp(AFTERIMAGE_THRESHOLD_MIN, AFTERIMAGE_THRESHOLD_MAX, velocity.length())
			afterimage.modulate.a = lerpf(0.0, AFTERIMAGE_OPACITY, weight)
			var tween = afterimage.create_tween()
			tween.tween_property(afterimage, ^"modulate:a", 0.0, lerpf(0.0, AFTERIMAGE_FADE_TIME, weight))
			tween.tween_callback(afterimage.queue_free)
			$AfterImages.add_child(afterimage)

	var hit_moving_wall: = false

	var collision_info = move_and_collide(velocity * delta * scale)
	if collision_info:
		if (state == $States / PMoving or (state == $States / PTelekinetic and velocity.length() > 32)):
			if collision_info.get_collider() is Baddie:
				hit_moving_wall = true
				collision_info.get_collider().death()
				sfxWallBump.play()
			elif collision_info.get_collider() is Block:
				collision_info.get_collider().hit(self)
				sfxWallBump.play()
			elif collision_info.get_collider() is Dog:
				sfxWallBump.play()
			else:
				var body_rid = collision_info.get_collider_rid()
				if PhysicsServer2D.body_get_mode(body_rid) == PhysicsServer2D.BODY_MODE_KINEMATIC:
					hit_moving_wall = true

				var direct_space: = PhysicsServer2D.space_get_direct_state(get_viewport().world_2d.space)
				var query: = PhysicsPointQueryParameters2D.new()
				query.position = global_position
				query.exclude = [get_rid()]
				query.collision_mask = 1 << 0
				query.collide_with_areas = false
				var in_wall = not direct_space.intersect_point(query).is_empty()

				var stick = mod_active("sticky")
				var sfx_stick: AudioStreamPlayer = $Sounds / Stick
				sfx_stick.pitch_scale = clampf(lerpf(
					STICK_PITCH_MIN, STICK_PITCH_MAX, 
					velocity.length() / 500.0
				), STICK_PITCH_MIN, STICK_PITCH_MAX)
				if in_wall:
					wall_death_count += 1
				if collision_info.get_collider() is TileMapLayer and collision_info.get_collider().is_in_group("GlassSolids"):
					if stick:
						if !sfx_stick.is_playing():
							sfx_stick.play()
					else:
						sfxClink.pitch_scale = randf_range(0.8, 1.1)
						sfxClink.play()
				else:
					if stick:
						if !sfx_stick.is_playing():
							sfx_stick.play()
					else:
						sfxWallBump.play()
						if !credits_mode:
							sfxWallBump.pitch_scale += 0.05
				if stick:
					velocity = Vector2.ZERO
					additional_velocity = Vector2.ZERO

					if in_wall:
						level.death(Level.DEATH_TYPES.WALL_STUCK)
		else:
			if !sfxPush.is_playing():
				sfxPush.play()

		velocity = velocity.bounce(collision_info.get_normal())
		if hit_moving_wall:
			global_position += velocity * delta
		if 100 * additional_velocity.length_squared() > velocity.length_squared():
			velocity *= sqrt(
				100 * additional_velocity.length_squared() / 
				velocity.length_squared()
			)

		var dog = collision_info.get_collider() as Dog
		if dog and dog.bounce_off_player:
			var angle = snappedf(global_position.angle_to_point(dog.global_position), PI / 4.0)
			dog.velocity = Vector2.from_angle(angle) * dog.velocity.length()



	key_rotation_offset = key_rotation_offset.rotated(delta * KEY_ROTATE_SPEED)

	if portal_sick:
		if portal_sick_timer <= 0:
			portal_sick = false
		else:
			portal_sick_timer -= 1


func clicked() -> void :
	if not credits_mode and level.mode == Level.MODES.NORMAL and !level.test_mode and Master.game_data.current_pthru != null:
		Master.game_data.current_pthru.total_clicks += 1
		print("clicke")
		if Master.game_data.current_pthru.total_clicks == 10:
			say(tr("GAME_ClickRemind1"))
		elif Master.game_data.current_pthru.total_clicks == 35:
			say(tr("GAME_ClickRemind2"))
		elif Master.game_data.current_pthru.total_clicks % 100 == 0:
			say(tr("GAME_ClickRemind3") % Master.game_data.current_pthru.total_clicks)


func say(text: String, priority: = false) -> void :
	if !speech_player.is_playing() or (speech_player.is_playing() and priority):
		speech_label.text = text
		speech_player.play(&"Show")


func mod_active(mod: String) -> bool:
	if get_parent() is EditorLevel:
		return get_parent().mod_data.mods[mod]
	return not credits_mode and (level.mode == Level.MODES.NORMAL or level.mode == Level.MODES.ENDLESS) and !level.test_mode and level.mod_data.mods[mod]
