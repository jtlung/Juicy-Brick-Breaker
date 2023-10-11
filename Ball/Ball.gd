extends RigidBody2D

var min_speed = 100.0
var max_speed = 600.0
var speed_multiplier = 1.0
var accelerate = false
var Effects = null
var BallHit = load("res://Effects/BallHit.tscn")
var released = true
var initial_velocity = Vector2.ZERO
var distort_effect = 0.0002
var BaseSize = Vector2(1,1)

func _ready():
	contact_monitor = true
	max_contacts_reported = 8
	if Global.level < 0 or Global.level >= len(Levels.levels):
		Global.end_game(true)
	else:
		var level = Levels.levels[Global.level]
		min_speed *= level["multiplier"]
		max_speed *= level["multiplier"]
	

func _on_Ball_body_entered(body):
	if released:
		bounceFX()
		if body.has_method("hit"):
			body.hit(self)
			accelerate = true
			
func bounceFX():
	var camera = get_node_or_null("/root/Game/Camera")
	if camera != null:
		camera.add_trauma(1)
	Effects = get_node_or_null("/root/Game/Effects")
	var effect = BallHit.instantiate()
	var Dir = position.direction_to(position+linear_velocity)
	var Angle = Dir.angle()
	effect.position = position
	effect.rotation = Angle+PI/2
	#$Sprites.rotation = effect.rotation
	Effects.add_child(effect)


func _input(event):
	if not released and event.is_action_pressed("release"):
		var padFx = get_node_or_null("/root/Game/Paddle_Container/Paddle/Launch")
		if padFx != null:
			padFx.global_position = global_position
			padFx.rotation = initial_velocity.angle()+PI/2
			padFx.get_node("pew").emitting = true
			var camera = get_node_or_null("/root/Game/Camera")
			if camera != null:
				camera.add_trauma(3)
		apply_central_impulse(initial_velocity)
		released = true

func distort():
	var scalar = linear_velocity.length()*.0005
	$Sprites.scale = BaseSize+Vector2(scalar,-scalar)
	$Sprites.rotation = linear_velocity.angle()-rotation
		
func _integrate_forces(state):
	if not released:
		var paddle = get_node_or_null("/root/Game/Paddle_Container/Paddle")
		if paddle != null:
			state.transform.origin = Vector2(paddle.position.x, paddle.position.y - 40)	
	else:
		distort()
		
	if position.y > Global.VP.y + 100:
		die()
	if accelerate:
		state.linear_velocity = state.linear_velocity * 1.1
		accelerate = false
	if abs(state.linear_velocity.x) < min_speed * speed_multiplier:
		state.linear_velocity.x = sign(state.linear_velocity.x) * min_speed * speed_multiplier
	if abs(state.linear_velocity.y) < min_speed * speed_multiplier:
		state.linear_velocity.y = sign(state.linear_velocity.y) * min_speed * speed_multiplier
	if state.linear_velocity.length() > max_speed * speed_multiplier:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed * speed_multiplier
		
func change_size(s):
	BaseSize = s
	$CollisionShape2D.scale = s

func change_speed(s):
	speed_multiplier = s

func die():
	queue_free()
