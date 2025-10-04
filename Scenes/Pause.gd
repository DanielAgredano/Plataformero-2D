extends Node

@onready var sprite_2d = %Sprite2D
@onready var pauseSound = $Sprite2D/pauseSound

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var pausePressed = Input.is_action_just_pressed("pause")
	if pausePressed:
		if not paused:
			get_tree().paused = true
			paused = true
			sprite_2d.show()
			pauseSound.play()
		else:
			get_tree().paused = false
			paused = false
			sprite_2d.hide()
