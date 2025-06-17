extends Control


@onready var icon = $Icon
@onready var count_label = $CountLabel

var item_id: String = ""
var count: int = 1

func set_item(id: String, amount: int = 1):
	item_id = id
	count = amount
	
	var item_data = ItemDB.get_item_data(id)
	if item_data:
		var icon_path = "res://Assets/Items/%s.png" % item_data.get("icon", "default")
		icon.texture = load(icon_path)
	else:
		icon.texture - null
	
	count_label.text = "x%d" % count if count > 1 else ""
