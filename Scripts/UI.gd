extends CanvasLayer

@onready var message_log: RichTextLabel = $PanelContainer/MarginContainer/RichTextLabel

func _ready():
	if message_log:
		print("✅ MessageBox.gd: message_log ready:", message_log.name)
	else:
		push_error("❌ MessageBox.gd: Could not find message_log!")

func say(message: String) -> void:
	if message_log:
		message_log.append_text(message + "\n")
		message_log.scroll_to_line(message_log.get_line_count())
	else:
		push_warning("⚠️ Tried to say but message_log is null.")
