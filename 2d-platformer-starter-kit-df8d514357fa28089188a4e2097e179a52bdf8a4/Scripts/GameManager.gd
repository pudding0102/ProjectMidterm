# This script is an autoload, that can be accessed from any other script!

extends Node2D

var score : int = 0
var death : int = 0
var key : int = 0

# Adds 1 to score variable
func add_score():
	score += 1
	
func add_death():
	death += 1
	
func add_key():
	key = 1

# Loads next level
func load_next_level(next_scene : PackedScene):
	SceneTransition.load_scene(next_scene)
