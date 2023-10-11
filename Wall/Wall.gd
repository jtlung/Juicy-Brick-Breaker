extends StaticBody2D

var decay = 0.01

func _ready():
	pass

func _physics_process(_delta):
	pass

func hit(_ball):
	var sfx = get_node_or_null("/root/Game/wall")
	if sfx != null:
		sfx.pitch_scale = (1+Global.combo/35.0)*randf_range(1,1.015)
		sfx.play()
