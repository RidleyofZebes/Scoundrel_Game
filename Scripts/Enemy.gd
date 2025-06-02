extends "res://Scripts/EntityBase.gd"

@export var enemy_id: String = ""
var active := false
var display_name: String = "???"
var weapon: String = "fist"

func _ready():
	super._ready()
	if GlobalEnemyData.enemy_defs.has(enemy_id):
		var data = GlobalEnemyData.enemy_defs[enemy_id]
		name = enemy_id
		display_name = data.get("name", "???")
		var health = data.get("hp", 10)
		var vision_mode = data.get("viewrange", 6)
		examine_text = data.get("examine", "...")
		weapon = data.get("weapon", "fist")
		var damage_array = data.get("damage", [1, 4])
		damage_range = Vector2i(damage_array[0], damage_array[1])
		var sprite_path = data.get("sprite", "")
		if sprite_path != "":
			var texture = load(sprite_path)
			$EntitySprite.texture = texture
		else:
			push_warning("No sprite defined for " + enemy_id)
		print("Spawned ", name)
	else:
		push_error("Unknown enemy ID: " + enemy_id)

func take_turn():
	if moving: return
	
	if not player:
		print("Enemy has no player reference!")
		return
			
	var dx = player.grid_x - grid_x
	var dy = player.grid_y - grid_y
	var dist = abs(dx) + abs(dy)
	
	if dist == 1:
		print("Enemy Attacks!")
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var damage = randi_range(damage_range[0], damage_range[1])
		MessageBox.say("The %s attacks you with %s for %d damage" % [display_name, weapon, damage])
		player.take_damage(0) # MARKED 0 FOR DEBUG - CHANGE BEFORE RELEASE
		return
	
	var move_dir := Vector2i.ZERO
	if abs(dx) > abs(dy):
		move_dir.x = sign(dx)
	else:
		move_dir.y = sign(dy)
		
	if try_move(move_dir.x, move_dir.y):
		print("Enemy moves toward player.")
	else:
		print("Enemy failed to move.")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		print("Enemy taking turn...")
		take_turn()
		active = false
