extends Node2D
var songs = [
	load("res://Assets/Music/adriftstars.mp3"),
	load("res://Assets/Music/gymnopedie.mp3"),
	load("res://Assets/Music/moonlight.mp3"),
	load("res://Assets/Music/nocturne.mp3"),
	load("res://Assets/Music/sunset.mp3"),
	load("res://Assets/Music/winter.mp3"),
]

func _ready():
	if Global.level < 0 or Global.level >= len(Levels.levels):
		Global.end_game(true)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var level = Levels.levels[Global.level]
		var song = songs[randi_range(1,songs.size())]
		var music = get_node_or_null("/root/Game/music")
		if music != null:
			music.stream = song
			music.play()
		var margin = level["layout_start"]
		var index = level["layout_spacing"]
		var layout = level["layout"]
		var Brick_Container = get_node_or_null("/root/Game/Brick_Container")
		Global.time = level["timer"]
		if Brick_Container != null:
			var Brick = load("res://Brick/Brick.tscn")
			for rows in range(len(layout)):
				for cols in range(len(layout[rows])):
					if layout[rows][cols] > 0:
						var brick = Brick.instantiate()
						brick.new_position = Vector2(margin.x + index.x*cols, margin.y + index.y*rows)
						brick.position = Vector2(brick.new_position.x,-100)
						brick.score = layout[rows][cols]
						Brick_Container.add_child(brick)
		var Instructions = get_node_or_null("/root/Game/UI/Instructions")
		if Instructions != null:
			Instructions.set_instructions(level["name"],level["instructions"])
