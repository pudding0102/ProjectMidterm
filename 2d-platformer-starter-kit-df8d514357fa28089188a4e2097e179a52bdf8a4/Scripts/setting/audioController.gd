extends Node

signal music_volume_changed(volume)
signal sfx_volume_changed(volume)

const CONFIG_PATH = "user://audio_settings.cfg"

# กำหนดไฟล์เสียงโดยตรง
const MUSIC_FILES = {
	"gameplay": "res://Assets/Sound/gamePlay/GameMusic.mp3",
	"boss_battle": "ใส่ path ไฟล์เพลง"
}

const SFX_FILES = {
	"attack" : "ใส่ path ไฟล์เพลง",
	"jump": "ใส่ path ไฟล์เพลง",
	"collect": "ใส่ path ไฟล์เพลง",
	"damage": "ใส่ path ไฟล์เพลง",
	"victory": "ใส่ path ไฟล์เพลง"
}

var music_volume: float = 0.8
var sfx_volume: float = 0.8
var music_bus: int
var sfx_bus: int
var music_player: AudioStreamPlayer

func _ready():
	#สร้าง music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	load_settings()
	apply_audio_settings()

#ตั้งค่าระดับเสียง
func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	apply_audio_settings()
	save_settings()
	emit_signal("music_volume_changed", music_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	apply_audio_settings()
	save_settings()
	emit_signal("sfx_volume_changed", sfx_volume)

func get_music_volume() -> float: 
	return music_volume
	
func get_sfx_volume() -> float: 
	return sfx_volume

#ใช้งานการตั้งค่าเสียง
func apply_audio_settings():
	if music_bus != -1:
		var db_volume = linear_to_db(music_volume)
		print("Music bus volume (dB): ", db_volume)
		AudioServer.set_bus_volume_db(music_bus, db_volume)
		AudioServer.set_bus_mute(music_bus, music_volume == 0.0)
		
	# ตั้งค่า SFX bus
	if sfx_bus != -1:
		var db_volume = linear_to_db(sfx_volume)
		print("SFX bus volume (dB): ", db_volume)
		AudioServer.set_bus_volume_db(sfx_bus, db_volume)
		AudioServer.set_bus_mute(sfx_bus, sfx_volume == 0.0)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	var error = config.save(CONFIG_PATH)
	if error != OK:
		print("Error saving audio settings: ", error)
		
#โหลดการตั้งค่า
func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		music_volume = config.get_value("audio", "music_volume", 0.8)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
		print("Loaded audio settings - Music: ", music_volume, " SFX: ", sfx_volume)
	else:
		print("Using default audio settings")

#Music
func play_music(name: String, loop := true):
	if not MUSIC_FILES.has(name):
		print("Music not found:", name)
		return
	var music = load(MUSIC_FILES[name])
	if music:
		music_player.stop()
		music_player.stream = music
		music_player.finished.connect(_on_music_finished if loop else Callable())
		music_player.play()

func _on_music_finished():
	music_player.play()
	
func stop_music():
	music_player.stop()
	
func pause_music():
	music_player.stream_paused = true

func resume_music():
	music_player.stream_paused = false

#SFX
func play_sfx(name: String):
	if not SFX_FILES.has(name):
		print("SFX not found:", name)
		return
	var sfx = load(SFX_FILES[name])
	if sfx:
		var player = AudioStreamPlayer.new()
		player.stream = sfx
		player.bus = "SFX"
		add_child(player)
		player.play()
		await get_tree().create_timer(sfx.get_length()).timeout
		player.queue_free()
