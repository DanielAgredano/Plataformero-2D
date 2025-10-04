extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -1300.0
const TERMINAL_VELOCITY = 1200.0
var facing = 1
var groundPounding = false
var groundPoundCooldown = false
var twirling = false
var sliding = false
var dead = false
@export var deathFall = false

@onready var sprite_2d = $Sprite2D
@onready var ground_pound_timer = $GroundPoundTimer
@onready var ground_pound_cooldown = $GroundPoundCooldown
@onready var twirl_cooldown = $TwirlCooldown
@onready var twirl_gp_cooldown = $TwirlGPCooldown
@onready var coyote = $Coyote
@onready var jumpSound = $Sounds/Jump
@onready var kickSound = $Sounds/kick
@onready var spinSound = $Sounds/spin
@onready var poundSound = $Sounds/pound
@onready var twirlSound = $Sounds/twirl
@onready var slideSound = $Sounds/slide

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var wasOnFloor = false
var clear = false

func _ready():
	Game.mario = $"."

func jump():
	velocity.y = JUMP_VELOCITY * (1 + 0.15*(abs(velocity.x)/SPEED))
	
func bounce():
	if not groundPounding:
		velocity.y = JUMP_VELOCITY * (1.0 if Input.is_action_pressed("jump") else 0.4)
	groundPounding = false
	
func canWallJump(direction):
	return is_on_wall_only() and get_wall_normal().x == -direction and not groundPounding
	
func isFalling():
	return velocity.y > 0
	
func isGoingBackwards(direction):
	if not velocity.x or not direction:
		return false
	var movingDir = 1 if velocity.x > 0 else -1
	return movingDir != direction

func animationActive(animation):
	return not ((sprite_2d.animation == animation and not sprite_2d.is_playing()) or sprite_2d.animation != animation)

func getAccel():
	if sprite_2d.animation == "slide": return 40
	if not is_on_floor(): return 50
	return 20

func _physics_process(delta):
	if dead:
		if deathFall:
			velocity.y += gravity * 4 * delta
		move_and_slide()
		return
	#print("Falling" if isFalling() else "Not falling")
	var running = Input.is_action_pressed("run")
	var direction = Input.get_axis("left", "right")
	var jumped = Input.is_action_just_pressed("jump")
	var downTap = Input.is_action_just_pressed("down")
	var upTap = Input.is_action_just_pressed("up")
	
	if clear:
		running = false
		direction = 1.0
		jumped = false
		downTap = false
		upTap = false
	
	sprite_2d.speed_scale = 1 if not running and is_on_floor() else 2
	
	if groundPoundCooldown and ground_pound_cooldown.is_stopped():
		groundPounding = false
		groundPoundCooldown = false
	
	if upTap and groundPounding and not groundPoundCooldown and not twirling:
		groundPounding = false
		velocity.y = TERMINAL_VELOCITY*0.1
	
	if groundPounding:
		direction = 0
		jumped = false
	
	if is_on_floor() or not animationActive("twirl"):
		twirling = false
	
	if abs(velocity.x)>0 and direction and not twirling:
		sprite_2d.play("Walk")
	elif not groundPounding and not twirling:
		sprite_2d.animation = "default"
		
	#Airborne.
	if not is_on_floor():
		if upTap  and twirl_cooldown.is_stopped() and not canWallJump(direction):
			if isFalling():
				velocity.y = TERMINAL_VELOCITY*0
			sprite_2d.play("twirl")
			twirl_cooldown.start()
			twirlSound.play()
			twirling = true
			
		if downTap and not groundPounding:
			sprite_2d.play("groundPound")
			ground_pound_timer.start()
			twirl_cooldown.start()
			spinSound.play()
			groundPounding = true
			direction = 0
			jumped = false
			velocity.x = 0
			velocity.y = 0
			
		if canWallJump(direction) and isFalling():
			velocity.y = TERMINAL_VELOCITY*0.15
			
		elif velocity.y < TERMINAL_VELOCITY and ground_pound_timer.is_stopped() and coyote.is_stopped():
			velocity.y += gravity * 4 * delta
			
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y = move_toward(velocity.y, 0, -velocity.y * 0.8)
		
		if twirling and isFalling():
			velocity.y = TERMINAL_VELOCITY*0.2
			
		if groundPounding and ground_pound_timer.is_stopped():
			velocity.y = TERMINAL_VELOCITY * 1.5
			
		if not groundPounding and not twirling:
			sprite_2d.animation = "Jump"
		
	else:
		if groundPounding and not groundPoundCooldown:
			ground_pound_cooldown.start()
			poundSound.play()
			groundPoundCooldown = true
		if direction and isGoingBackwards(direction) and running:
			sprite_2d.animation = "slide"
		
	# Handle jump.
	if isFalling() and wasOnFloor:
		coyote.start()
	
	if jumped and (is_on_floor() or not coyote.is_stopped()):
		jump()
		coyote.stop()
		jumpSound.play()
	
	if(jumped and canWallJump(direction)):
		jump()
		kickSound.play()
		velocity.x = SPEED * -2.5 * -get_wall_normal().x
	
	if direction:
		sprite_2d.flip_h = direction < 0
		velocity.x = move_toward(velocity.x, SPEED * (1.0 if not running else 1.4) * direction, getAccel())
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED/10)
		
	if canWallJump(direction) and isFalling():
		sprite_2d.animation = "slide"
		if not slideSound.playing:
			slideSound.volume_db = -80.0
			slideSound.playing = true
		if slideSound.volume_db <= -17.0:
			slideSound.volume_db += 5.0
		else:
			slideSound.volume_db = -17.0
		sprite_2d.flip_h = direction > 0
	else:
		slideSound.playing=false	
	
	wasOnFloor = is_on_floor()
	move_and_slide()

func death(fall = false):
	if dead: return
	dead = true
	Game.music.stop()
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	velocity = Vector2(0,0)
	Game.GM.fadeOut()
	$AP_anim.play("death" if not fall else "deathFall")


func hurt(area: Area2D):
	death(area.name == "Pit")

func restart():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func setClear():
	clear = true
