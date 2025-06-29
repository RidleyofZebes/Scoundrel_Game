extends CanvasLayer

@onready var log_list: VBoxContainer = $LogBox/TextMargin/ScrollContainer/LogList
const MAX_LOG_LINES := 7
const TYPING_SPEED := 0.01 # TODO: Add to options menu

var _message_queue: Array[String] = []
var _is_typing: bool = false

func say(message: String) -> void:
	_message_queue.append(message)
	if not _is_typing:
		_process_queue()
	
func _process_queue() -> void:
	if _message_queue.size() == 0:
		_is_typing = false
		return
	_is_typing = true
	var message = _message_queue.pop_front()
	var label = Label.new()
	label.text = ""
	label.modulate = Color.WHITE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_list.add_child(label)
	log_list.move_child(label, 0)
	await typing_message(label, message)
	
	for i in log_list.get_child_count():
		var child = log_list.get_child(i)
		var fade = clamp(1.0 - float(i) * 0.25, 0.2, 1.0)
		child.modulate.a = fade
		
	call_deferred("_cleanup_log_lines")
	_process_queue()
	
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
