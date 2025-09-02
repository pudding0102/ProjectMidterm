extends CharacterBody2D

# --------- VARIABLES ---------- #
@export_category("Player Properties")
@export var move_speed : float = 300
@export var jump_force : float = 1000
@export var gravity : float = 1200
@export var max_jump_count : int = 2
var jump_count : int = 2

@export_category("Toggle Functions")
@export var double_jump : bool = false

# เพิ่มตัวแปรสำหรับตรวจสอบตกแมพ
@export var fall_death_height : float  # ความสูงที่ถือว่าตกแมพ

var is_grounded : bool = false
var ground_time = 0.0
var step_time = 0.0

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles

# --------- BUILT-IN FUNCTIONS ---------- #

func _ready():
	# ตรวจสอบว่ามี spawn_point หรือไม่
	if not spawn_point:
		spawn_point = self  # ถ้าไม่มีให้ใช้ตำแหน่งเริ่มต้นของตัวละคร

func _process(delta):
	movement(delta)
	player_animations()
	flip_player()
	
	# ตรวจสอบการตกแมพ
	check_fall_death()
	
	# ตัดแรงกระโดดเมื่อปล่อยปุ่ม
	if Input.is_action_just_released("Jump") and velocity.y < -200:
		velocity.y = -200

# --------- ฟังก์ชันตรวจสอบตกแมพ ---------- #

func check_fall_death():
	# ตรวจสอบว่าตัวละครตกจากแมพหรือไม่
	if global_position.y > fall_death_height:
		handle_fall_death()

func handle_fall_death():
	GameManager.add_death()
	$Death.play()
	death_particles.emitting = true
	respawn()

# --------- ฟังก์ชัน respawn ---------- #

func respawn():
	# ย้ายกลับไปที่ spawn point
	if spawn_point:
		global_position = spawn_point.global_position
	else:
		# ถ้าไม่มี spawn point ให้ย้ายไปที่ตำแหน่ง (0, 0)
		global_position = Vector2.ZERO
	
	# รีเซ็ต velocity
	velocity = Vector2.ZERO
	
	# รีเซ็ต animation
	scale = Vector2.ONE

# --------- CUSTOM FUNCTIONS ---------- #

func movement(delta):
	# Gravity
	if !is_on_floor():
		velocity.y += gravity * delta
		ground_time = 0
	elif is_on_floor():
		jump_count = max_jump_count
		if ground_time == 0:
			play_step_sound()
		ground_time += delta
	
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	velocity.x = inputAxis * move_speed
	move_and_slide()
	
	if inputAxis != 0 and is_on_floor():
		step_time += delta * 3
	if step_time >= 1:
		play_step_sound()
		step_time = 0

func play_step_sound():
	var step = randi_range(1,4)
	match step:
		1: $Step.play()
		2: $Step2.play()
		3: $Step3.play()
		4: $Step4.play()

func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

func jump():
	jump_tween()
	$Jump.play()
	velocity.y = -jump_force

# --------- Animations ---------- #

func player_animations():
	particle_trails.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			$AnimationPlayer.play("Walk")
			$AnimationPlayer.speed_scale = 2
			player_sprite.play("Walk", 1.5)
		else:
			$AnimationPlayer.play("Idle")
			$AnimationPlayer.speed_scale = 1
			player_sprite.play("Idle")
	else:
		$AnimationPlayer.play("Jump")
		$AnimationPlayer.speed_scale = 1
		player_sprite.play("Jump")

func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
		$Skeleton2D.scale.x = -0.185
		$Parts.scale.x = -0.185
	elif velocity.x > 0:
		player_sprite.flip_h = false
		$Skeleton2D.scale.x = 0.185
		$Parts.scale.x = 0.185

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
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

# --------- SIGNALS ---------- #

func _on_collision_body_entered(_body):
	if _body.is_in_group("Enemy") and ground_time > 0.1:
		GameManager.add_death()
		$Death.play()
		death_particles.emitting = true
		death_tween()
	elif _body.is_in_group("Traps"):
		GameManager.add_death()
		$Death.play()
		death_particles.emitting = true
		death_tween()
