extends Area2D

@onready var gm = $"../../GM"
@onready var sprite = $AnimatedSprite2D
@onready var coin_sound = $CoinSound
var collected = false

func _on_body_entered(_body):
	#despawn()
	pass

func collect(_object = null):
	print("Entered")
	$Activation/Shape.call_deferred("set_disabled",true)
	coin_sound.play()
	gm.addCoin()
	collected = true
	sprite.visible = false

func _process(_delta):
	#print(name)
	if collected and not coin_sound.playing:
		queue_free()

func despawn():
	queue_free()
