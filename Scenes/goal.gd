extends Node2D

const item = {
	0:"Mushroom",
	1:"Flower",
	2:"Star",
}

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func startClear(_area):
	$AnimationPlayer.play("Clear")
	$Sprite.play(item[$Sprite.frame])
	$"../Barrier/Shape".call_deferred("set_disabled",true)
	Game.mario.setClear()

func resetCoins():
	Game.coins = 0
