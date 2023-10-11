extends CharacterBody2D

var target = Vector2.ZERO
var speed = 10.0
var width = 0
var width_default = 0
var decay = 0.02
var originalPos

func _ready():
	originalPos = $Sprites.position
	width = $CollisionShape2D.get_shape().size.x
	width_default = width
	target = Vector2(Global.VP.x / 2, Global.VP.y - 80)

func _physics_process(_delta):
	target.x = clamp(target.x, width/2, Global.VP.x - width/2)
	position = target
	for c in $Powerups.get_children():
		c.payload()

func _input(event):
	if event is InputEventMouseMotion:
		target.x += event.relative.x

func hit(ball):
	var dir = ball.position.direction_to(position)
	var magnitude = ball.linear_velocity.length()/20
	var targetPos = $Sprites.position+dir*magnitude
	var tweenTime = .2
	var tween = create_tween()
	tween.tween_property($Sprites, "position", targetPos, tweenTime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprites, "position", originalPos, tweenTime).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func powerup(payload):
	for c in $Powerups.get_children():
		if c.type == payload.type:
			c.queue_free()
	$Powerups.call_deferred("add_child", payload)
