extends Control

@onready var score_texture = %Score/ScoreTexture
@onready var score_label = %Score/ScoreLabel
var currentscore = GameManager.score

var key = GameManager.key

func _process(_delta):
	# Set the score label text to the score variable in game maanger script
	score_label.text = "x %d" % GameManager.score
	%Score/DeathLabel.text = "x %d" % GameManager.death
	if currentscore != GameManager.score:
		currentscore = GameManager.score
		$Coin.play()
	if key != GameManager.key:
		key = GameManager.key
		%Score/Key.visible = true
		$Coin.play()
