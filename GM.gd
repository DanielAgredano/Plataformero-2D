extends Node

@onready var coin_counter = %CoinCounter
@onready var background_music: AudioStreamPlayer = $"../Background Music"


var coins = 0

func _ready() -> void:
	Game.GM = $"."
	Game.music = background_music
	Game.coin_counter = coin_counter
	coin_counter.text = str(Game.coins).pad_zeros(2) + " "

func addCoin():
	coins += 1
	coin_counter.text = str(coins).pad_zeros(2) + " "

func addLife():
	$"../1UP".play()

func fadeOut():
	$"../UI/ColorRect/AP_fade".play("fadeOut")
