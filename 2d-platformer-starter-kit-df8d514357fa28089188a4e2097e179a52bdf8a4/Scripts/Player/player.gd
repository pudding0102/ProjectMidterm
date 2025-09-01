extends CharacterBody2D

# --------- VARIABLES ---------- #
@export_category("Player Properties")
const SPEED = 300.0
const JUMP_FORCE = -400.0
const GRAVITY = 980.0

@export var max_jump_count : int = 2
var jump_count : int = 2

@export_category("Toggle Functions")
@export var double_jump : bool = false

var is_grounded : bool = false
var ground_time : float = 0.0
var step_time : float = 0.0

@onready var player_sprite = $Pockie
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var state_machine = $StateMachine

# --------- BUILT-IN FUNCTIONS ---------- #
func _ready():
	#ตั้งค่า reference ให้ state machine
	for state in state_machine.get_children():
		state.player = self

func _physics_process(_delta):
	movement(_delta)
	handle_jumping()
	move_and_slide()
	flip_player()
	
# --------- CUSTOM FUNCTIONS ---------- #

func movement(delta):
	#Gravity
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		ground_time = 0
		
	elif is_on_floor():
		jump_count = max_jump_count
		ground_time += delta
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	velocity.x = inputAxis * SPEED
	
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1
		
func jump():
	velocity.y = JUMP_FORCE
	
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

# --------- Update Animetion ---------- #

func update_animation():
	if !is_on_floor():
		player_sprite.play("jump")
	elif abs(velocity.x) > 0:
		player_sprite.play("walk")
	else:
		player_sprite.play("idle")

# --------- SIGNALS ---------- #

func _on_collision_body_entered(_body):
	if (_body.is_in_group("Enemy") and ground_time > 0.1) or _body.is_in_group("Traps"):
		die()

func die():
	GameManager.add_death()
	$Death.play()
	death_particles.emitting = true
	death_tween()
	#ส่ง signal ไป state machine เพื่อเปลี่ยน state
	if state_machine.has_method("change_state"):
		state_machine.change_state("Death_state")
