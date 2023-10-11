extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$stars.emitting = true
	$fwoosh.emitting = true
	$ring.emitting = true
	await get_tree().create_timer(1.5,false).timeout
	queue_free()
