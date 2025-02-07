# scripts/resources/item.gd
extends Area3D

class_name Item

var item_name = ""
var item_type = ""

func _ready():
	connect("body_entered", self, "_on_Item_body_entered")

func _on_Item_body_entered(body):
	if body.name == "Player":
		body.pick_up_item(self)

func interact():
	pass
