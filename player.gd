extends Area2D
signal hit  # For when the player collides with a mob
signal power_up_collected  # For when the player collects a power-up

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var speed_multiplier = 1.0 # Default speed multiplier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * (speed * speed_multiplier)  # Apply the speed multiplier
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x < 0:
		$AnimatedSprite2D.animation = "walkLeft"
	if velocity.x > 0:
		$AnimatedSprite2D.animation = "walkRight"
	if velocity.x == 0:
		$AnimatedSprite2D.animation = "still"

# Function to handle body entered event
func _on_body_entered(body: Node2D) -> void:
	# Check if the collided body is a mob
	if body.is_in_group("mobs"):
		_on_mob_collision(body)
	elif body.is_in_group("powerups"):
		_on_power_up_collision(body)

# Handle mob collision (player hit by a mob)
func _on_mob_collision(mob: Node2D) -> void:
	hide()
	hit.emit()

	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

# Handle power-up collision (player collects a power-up)
func _on_power_up_collision(power_up: Node2D) -> void:
	# Increase the player's speed by 1.2x
	speed_multiplier *= 5  # Multiply the current speed by 1.2
	power_up_collected.emit()  # Emit a signal for collecting the power-up

	# You might want to hide or remove the power-up from the scene
	power_up.queue_free()

# Function to reset the player and start at a specific position
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	speed_multiplier = 1.0  # Reset speed multiplier when the game starts
