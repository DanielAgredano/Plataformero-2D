extends Node

var coin_counter
var music
var GM
var mario

var coins = 0

func addCoin():
	coins += 1
	if coins > 99:
		coins -= 100
		GM.addLife()
	coin_counter.text = str(coins).pad_zeros(2) + " "
