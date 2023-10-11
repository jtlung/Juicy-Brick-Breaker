extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false
var worry = 0.0

var powerup_prob = 0.1

var colors = [
	Color8(224,49,49)
	,Color8(255,146,43)
	,Color8(255,212,59)
	,Color8(148,216,45)
	,Color8(34,139,230)
	,Color8(132,94,247)
	,Color8(190,75,219)
	,Color8(134,142,150)
]
var color_index = 0

func _ready():
	randomize()
	var faces = $Faces.get_children()
	var face = faces[randi_range(0,1-faces.size())]
	face.show()
	color_index = 7
	if score >= 40:
		color_index = (100-score)/10.0
	$Sprite2D.modulate = colors[color_index]
	var dir = Vector2(randf_range(-1,1),-1).normalized()
	position = new_position+dir*1500
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var tweenTime = 3*randf_range(.5,1)
	scale = Vector2(.25,.25)
	tween.set_parallel(true)
	tween.tween_property(self, "position", new_position, tweenTime).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(.9,.9), tweenTime).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func _physics_process(delta):
	if worry > 0:
		worry -= .25*delta
	elif worry <= 0 and $scared.visible == true:
		worry = 0
		$scared.hide()
		$Faces.show()
	if dying:
		pass
		#queue_free()

func hit(ball):
	var bricks = get_node_or_null("/root/Game/Brick_Container")
	die(ball)
	if bricks != null:
		print("shaboinger")
		for brick in bricks.get_children():
			if brick.dying != true:
				var tweenTime = .2*randf_range(.75,1)
				var tween = create_tween()
				var dir = ball.position.direction_to(brick.position)
				var magnitude = ball.position.distance_to(brick.position)
				if magnitude < 115:
					brick.worry += 1.0
					brick.get_node("scared").show()
					brick.get_node("Faces").hide()
				var targetPos = brick.position+dir*(magnitude/15*randf_range(1,1.5))
				tween.tween_property(brick, "position", targetPos, tweenTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(brick, "position", brick.new_position, tweenTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func getColor():
	return colors[color_index]

func die(ball):
	dying = true
	collision_layer = 0
	$Faces.hide()
	$death.show()
	var tweenTime = .5
	var tween = create_tween()
	var dir = ball.position.direction_to(position)
	var targetPos = position+dir*90
	rotation += deg_to_rad(15*randi_range(-1,1))
	scale = scale*1.1
	tween.set_parallel(true)
	tween.tween_property(self, "position", targetPos, tweenTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0,0), tweenTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", rotation+PI, tweenTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	Global.update_score(score)
	var camera = get_node_or_null("/root/Game/Camera")
	if camera != null:
		camera.add_trauma(1)
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
	await get_tree().create_timer(tweenTime,false).timeout
	queue_free()
