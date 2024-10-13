extends Node

@export var mob_scene: PackedScene = preload("res://mob.tscn")
@export var speedUp_scene: PackedScene = preload("res://SpeedUpBuffScene.tscn")
@export var speedDown_scene: PackedScene = preload("res://SpeedDownBuffScene.tscn")
@export var asteroid_scene: PackedScene = preload("res://asteroid.tscn")
@export var power_up_scene: PackedScene = preload("res://power_up.tscn")

var score
var mob_initial_velocity = 200
var mob_final_velocity = 250
var buffs_initial_velocity = 200
var buffs_final_velocity = 250
var asteroid_initial_velocity = 100
var asteroid_final_velocity = 200

var powerup_initial_velocity = 200
var powerup_final_velocity = 250
var speedDifficulty = 0

func _ready():
	#$HUD.connect("start_game", self, "new_game")
	$HUD.start_game.connect(self.new_game)
	$Player.connect("power_up_collected", Callable(self, "_on_power_up_collected"))
	$MobTimer.wait_time = 1
	score = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func game_over():
	$ElevationTimer.stop()
	$MobTimer.stop()
	$SpeedUpBuffTimer.stop()
	$SpeedDownBuffTimer.stop()
	$PowerUpTimer.stop()
	$AsteroidTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	
func _on_start_timer_timeout():
	$MobTimer.start()
	$ElevationTimer.start()
	$SpeedUpBuffTimer.start()
	$SpeedDownBuffTimer.start()
	$PowerUpTimer.start()
	$AsteroidTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Convert 80 and 100 degrees to radians
	var direction = randf_range(1.39626, 1.74533)
	mob.rotation = direction
	
	if score % 10 == 0 and score != 0:
		speedDifficulty += 30
		$MobTimer.wait_time = max(0.5, $MobTimer.wait_time - 0.05)

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(mob_initial_velocity + speedDifficulty, mob_final_velocity + speedDifficulty), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)

func _on_elevation_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_asteroid_timer_timeout() -> void:
	var asteroid = asteroid_scene.instantiate()

	var asteroid_spawn_location = $AsteroidPath/AsteroidSpawnLocation
	asteroid_spawn_location.progress_ratio = randf()

	asteroid.position = asteroid_spawn_location.position

	var velocity = Vector2(randf_range(asteroid_initial_velocity, asteroid_final_velocity), 0.0)
	asteroid.linear_velocity = velocity

	add_child(asteroid)
	

func _on_power_up_collected():
	score += 3
	$HUD.update_score(score)
	
func _on_speedUpBuff_timer_timeout() -> void:
	var speedUpBuff = speedUp_scene.instantiate()

	# Choose a random location on Path2D
	var speedUpBuff_spawn_location = $SpeedUpBuffPath/SpeedUpBuffSpawnLocation
	speedUpBuff_spawn_location.progress_ratio = randf()
	
	# Set rotation explicitly to face down (PI / 2 radians)
	var direction = PI / 2
	speedUpBuff.rotation = direction

	# Set the position to the spawn location
	speedUpBuff.position = speedUpBuff_spawn_location.position

	# Set the velocity to move straight down
	var velocity = Vector2(0.0, randf_range(buffs_initial_velocity, buffs_final_velocity))  # Moving down (positive y)
	speedUpBuff.linear_velocity = velocity

	add_child(speedUpBuff)
	
func _on_speed_down_buff_timer_timeout() -> void:
	var speedDownBuff = speedDown_scene.instantiate()

	var speedDownBuff_spawn_location = $SpeedDownBuffPath/SpeedDownBuffSpawnLocation
	speedDownBuff_spawn_location.progress_ratio = randf()
	
	var direction = PI / 2
	speedDownBuff.rotation = direction

	# Set the position to the spawn location
	speedDownBuff.position = speedDownBuff_spawn_location.position

	# Set the velocity to move straight down
	var velocity = Vector2(0.0, randf_range(buffs_initial_velocity, buffs_final_velocity))  # Moving down (positive y)
	speedDownBuff.linear_velocity = velocity

	add_child(speedDownBuff)
