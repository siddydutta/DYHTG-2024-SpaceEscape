extends RigidBody2D

var screen_size # Size of the game window.

var sprite = $AnimatedSprite2D


func _ready():
	sprite.play("powerup")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimatedSprite2D.animation = "powerup"
	$AnimatedSprite2D.play()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
