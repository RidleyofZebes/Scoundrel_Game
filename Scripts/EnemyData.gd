extends Node
class_name EnemyRegistry

var enemy_defs

func _ready():
	var file = FileAccess.open("res://Data/enemy_types.yaml", FileAccess.READ)
	if file:
		var yaml_string = file.get_as_text()
		var result = YAML.parse(yaml_string)
		enemy_defs = result.get_data()
	else:
		push_error("Could not load enemy_types.yaml")

func get_random_enemy() -> String:
	var weighted_pool = []
	for id in enemy_defs.keys():
		var weight = int(enemy_defs[id].get("weight", 1))
		for i in range(weight):
			weighted_pool.append(id)
			
	if weighted_pool.is_empty():
		push_error("No enemies in weight pool!")
		return ""
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return weighted_pool[rng.randi_range(0, weighted_pool.size() - 1)]
