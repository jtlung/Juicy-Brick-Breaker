extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false

var powerup_prob = 0.1

func _ready():
	randomize()
	var faces = $Faces.get_children()
	var face = faces[randi_range(0,1-faces.size())]
	face.show()
	position = new_position

func _physics_process(_delta):
	if dying:
		queue_free()

func hit(_ball):
	die()

func die():
	dying = true
	collision_layer = 0
	$Sprite2D.hide()
	Global.update_score(score)
	if not Global.feverish:
		Global.update_fever(score)
	get_parent().check_level()
	if randf() < powerup_prob:
		var Powerup_Container = get_node_or_null("/root/Game/Powerup_Container")
		if Powerup_Container != null:
			var Powerup = load("res://Powerups/Powerup.tscn")
			var powerup = Powerup.instantiate()
			powerup.position = position
			Powerup_Container.call_deferred("add_child", powerup)
