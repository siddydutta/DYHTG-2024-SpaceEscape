extends Node

@export var mob_scene: PackedScene = preload("res://mob.tscn")
@export var power_up_scene: PackedScene = preload("res://power_up.tscn")

var score
var mob_initial_velocity = 150
var mob_final_velocity = 250
var powerup_initial_velocity = 50
var powerup_final_velocity = 100


func _ready():
	#$HUD.connect("start_game", self, "new_game")
	$HUD.start_game.connect(self.new_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func game_over():
	$ElevationTimer.stop()
	$MobTimer.stop()
	$PowerUpTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	
func _on_start_timer_timeout():
	$MobTimer.start()
	$ElevationTimer.start()
	$PowerUpTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Set the direction to be between 90 degrees (PI/2) and 180 degrees (PI)
	var direction = randf_range(PI / 2, PI)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(mob_initial_velocity, mob_final_velocity), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_elevation_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_power_up_timer_timeout() -> void:
	var powerUp = power_up_scene.instantiate()

	var powerUp_spawn_location = $PowerUpPath/PowerUpSpawnLocation
	powerUp_spawn_location.progress_ratio = randf()

	powerUp.position = powerUp_spawn_location.position

	var velocity = Vector2(randf_range(powerup_initial_velocity, powerup_final_velocity), 0.0)
	powerUp.linear_velocity = velocity

	add_child(powerUp)
