extends Node2D

func _input(event):
	if  event.is_action("inventory"):
		if event.pressed:
			# ПКМ нажата
			self.visible = true
			print("show")
		else:
			print("hide")
			# ПКМ отпущена
			self.visible = false
