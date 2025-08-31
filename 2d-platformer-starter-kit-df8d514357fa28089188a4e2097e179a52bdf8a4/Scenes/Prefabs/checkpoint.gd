extends Area2D

# You can change these to your likings
@export var amplitude := 4
@export var frequency := 5
@export var spawnpoint : Marker2D
var used = false

var time_passed = 0
var initial_position := Vector2.ZERO

func _ready():
	initial_position = $Sprite2D.position

func _process(delta):
	coin_hover(delta) # Call the coin_hover function

# Coin Hover Animation
func coin_hover(delta):
	time_passed += delta
	
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	$Sprite2D.position.y = new_y

# Coin collected
func _on_body_entered(body):
	if body.is_in_group("Player") && used == false:
		used = true
		spawnpoint.position = position + Vector2(0, -200)
		$Sound.play()
		var tween = create_tween()
		tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.1)
		await tween.finished
		$Sprite2D.visible = false
		$CoinSparkles.emitting = false
