extends CanvasLayer

@onready var log_list: VBoxContainer = $LogBox/TextMargin/ScrollContainer/LogList
const MAX_LOG_LINES := 10

func say(message: String) -> void:
	var label = Label.new()
	label.text = message
	label.modulate = Color.WHITE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_list.add_child(label)
	log_list.move_child(label, 0)
	
	for i in log_list.get_child_count():
		var child = log_list.get_child(i)
		var fade = clamp(1.0 - float(i) * 0.1, 0.2, 1.0)
		child.modulate.a = fade
		
	call_deferred("_cleanup_log_lines")
		
func _cleanup_log_lines() -> void:
	var over_limit := log_list.get_child_count() - MAX_LOG_LINES
	if over_limit > 0:
		for i in range(over_limit):
			var oldest = log_list.get_child(log_list.get_child_count() - 1)
			if is_instance_valid(oldest):
				oldest.queue_free()
