extends CanvasLayer

signal button_pressed(id: String)

@onready var title_label: Label = %Title
@onready var body_label: Label = %Body
@onready var buttons: HBoxContainer = %Buttons

func _ready() -> void:
	hide()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("exit"):
		close()

func open(title: String, body: String, button_defs: Array = [{"id": "close", "text": "Close"}]) -> void:
	title_label.text = title
	body_label.text = body
	for child in buttons.get_children():
		child.queue_free()
	for def in button_defs:
		var btn := Button.new()
		btn.text = def.text
		btn.disabled = def.get("disabled", false)
		btn.pressed.connect(_on_button.bind(def.id))
		buttons.add_child(btn)
	show()
	get_tree().paused = true
	
func close() -> void:
	hide()
	get_tree().paused = false
	
func _on_button(id: String) -> void:
	close()
	button_pressed.emit(id)
