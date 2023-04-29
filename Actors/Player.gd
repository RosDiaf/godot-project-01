extends CharacterBody2D
class_name Player

enum { MOVE, CLIMB }

# Will load DefaultPlayerMovementData.tres
@export var moveData: Resource = preload("res://Resources/DefaultPlayerMovementData.tres") as PlayerMovementData
@onready var animatedSprite = $AnimatedSprite2D
@onready var ladderCheck = $LadderCheck
@onready var jumpBufferTimer: = $JumpBufferTimer
@onready var remoteTransform2D: = $RemoteTransform2D
@onready var particles: = $GPUParticles2D

var state = MOVE
var screensize
var double_jump = 1
var buffered_jump = false

func _ready():
	animatedSprite.frames = load("res://PlayerSkins/PlayerGreenSkin.tres")
	screensize = get_viewport_rect().size
	
# Will load different data for movement Player
# Call the method whenever you want the Player to go faster
func powerup():
	moveData = load("res://Resources/FastPlayerMovementData.tres")

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func move_state(input, delta):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
	
	apply_gravity(delta)
	set_animation(input, delta)
	set_animation_flip_h(input)
	
	if is_on_floor():
		# Reset Double Jump
		reset_double_jump()
		# Jump
		input_jump(delta)
	
	if !is_on_floor():
		# Double Jump
		input_double_jump()

	move_and_slide()
	just_landed()

func climb_state(input):
	if not is_on_ladder():
		state = MOVE
	if input.length() != 0: # Player is moving
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	velocity = input * moveData.CLIMB_SPEED
	move_and_slide()

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	apply_clamp(delta)
	match state:
		MOVE: move_state(input, delta)
		CLIMB: climb_state(input)
	
func apply_gravity(delta):
	velocity.y += moveData.GRAVITY * delta
	velocity.y = min(velocity.y, moveData.LANDING_ACCELERATION)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION * delta)
	
func apply_acceleration(amount,delta):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION * delta)
	
func apply_clamp(delta):
	position += velocity * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)
	
func input_jump(delta):
	if Input.is_action_pressed("ui_up") or buffered_jump:
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
			velocity.y = moveData.JUMP_RELEASE_FORCE
		if velocity.y > 0:
			velocity.y += moveData.ADDITIONAL_FALL_GRAVITY * delta
			
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			animatedSprite.animation = "Jump"
			velocity.y = moveData.JUMP_FORCE
			double_jump -= 1
		
	if Input.is_action_just_pressed("ui_up") and double_jump == 1:
		buffered_jump = true
		jumpBufferTimer.start()

func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT
	
func set_animation(input, delta):
	if input.x == 0:
		apply_friction(delta)
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x, delta)
		animatedSprite.animation = "Run"
		
func set_animation_flip_h(input):
	animatedSprite.flip_h = input.x > 0
	
func just_landed():
	var is_just_landed = is_on_floor()
	if is_just_landed:
		particles.emitting = true
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
func _on_jump_buffer_timer_timeout():
	buffered_jump = false
	
func player_died():
	queue_free()
	Events.emit_signal("player_died")

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

