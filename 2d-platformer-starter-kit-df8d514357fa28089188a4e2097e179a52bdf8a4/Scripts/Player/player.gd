extends CharacterBody2D

# --------- VARIABLES ---------- #
@export_category("Player Properties")
@export var move_speed : float = 300
@export var jump_force : float = 500
@export var gravity : float = 1200
@export var max_jump_count : int = 2
var jump_count : int = 2

@export_category("Toggle Functions")
@export var double_jump : bool = false

var is_grounded : bool = false

var ground_time : float = 0.0
var step_time : float = 0.0

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var state_machine = $StateMachine

# --------- BUILT-IN FUNCTIONS ---------- #
func _ready():
	for state in state_machine.get_children():
		if state.has_method("set_player_references"):
			state.set_player_references(self, player_sprite)

func _physics_process(delta):
	state_machine._physics_process(delta)
	flip_player()
	move_and_slide()
	
# --------- CUSTOM FUNCTIONS ---------- #

func movement(delta):
	# Gravity
	if !is_on_floor():
		velocity.y += gravity * delta
		ground_time = 0
	elif is_on_floor():
		jump_count = max_jump_count
		ground_time += delta
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	velocity.x = inputAxis * move_speed
	move_and_slide()
	
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1
		
func jump():
	velocity.y = -jump_force
	
func play_random_step_sound():
	var step = randi_range(1,4)
	match step:
		1: $Step.play()
		2: $Step2.play()
		3: $Step3.play()
		4: $Step4.play()
	
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

# --------- Tweens ---------- #

func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	velocity.y = -100
	await get_tree().create_timer(0.3).timeout
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

# --------- SIGNALS ---------- #

func _on_collision_body_entered(_body):
	if (_body.is_in_group("Enemy") and ground_time > 0.1) or _body.is_in_group("Traps"):
		GameManager.add_death()
		$Death.play()
		death_particles.emitting = true
		death_tween()
