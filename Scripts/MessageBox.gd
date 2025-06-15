extends CanvasLayer

@onready var log_list: VBoxContainer = $LogBox/TextMargin/ScrollContainer/LogList
const MAX_LOG_LINES := 7
const TYPING_SPEED := 0.01 # TODO: Add to options menu

func say(message: String) -> void:
	var label = Label.new()
	label.text = ""
	label.modulate = Color.WHITE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_list.add_child(label)
	log_list.move_child(label, 0)
	
	typing_message(label, message)
	
	for i in log_list.get_child_count():
		var child = log_list.get_child(i)
		var fade = clamp(1.0 - float(i) * 0.25, 0.2, 1.0)
		child.modulate.a = fade
		
	call_deferred("_cleanup_log_lines")
	
func typing_message(label: Label, message: String) -> void:
	await get_tree().process_frame
	
	for i in message.length():
		label.text = message.substr(0, i + 1)
		await get_tree().create_timer(TYPING_SPEED).timeout
		
func _cleanup_log_lines() -> void:
	var over_limit := log_list.get_child_count() - MAX_LOG_LINES
	if over_limit > 0:
		for i in range(over_limit):
			var oldest = log_list.get_child(log_list.get_child_count() - 1)
			if is_instance_valid(oldest):
				oldest.queue_free()
