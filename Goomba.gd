extends CharacterBody2D

var dead = false
var speed = -150.0

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var stompedSound = $stomped

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.x = speed
	velocity.y = 0

func _physics_process(delta):
	if is_on_wall():
		velocity.x = speed * -get_wall_normal().x
	if not is_on_floor():
		velocity.y += gravity * 4 * delta
	if dead and timer.is_stopped():
		visible = false
		if not stompedSound.playing:
			queue_free()
	if not dead:
		move_and_slide()

func _on_area_2d_body_entered(body):
	if(body.name == "Mario" and not dead):
		if not body.isFalling(): return
		$Hitbox/Shape.call_deferred("set_disabled",true)
		dead = true
		velocity.x = 0
		sprite.animation = "stomped"
		stompedSound.play()
		timer.start()
		body.bounce()
