extends CanvasLayer

@onready var node2d = $Node2D
@onready var control = node2d.get_node("Control")

func _ready():
	node2d.visible = false

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT :
		if event.is_pressed():
			node2d.visible = true
		else:
			node2d.visible = false

func _process(delta):
	control.visible = node2d.visible
