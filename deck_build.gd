extends Node2D

@export_group("卡组分配")
@export var scene_1 : Node
@export var scene_2 : Node
@export var scene_3 : Node
@export var scene_4 : Node

func  _ready() -> void:
	add_new_card("shoot" ,scene_1, false)
	add_new_card("shoot" ,scene_2, false)
	add_new_card("load" ,scene_3, false)
	add_new_card("avoid" ,scene_4, false)
	print("ready")

func add_new_card(cardName, cardDeck, _isOppoent, _caller = scene_1,  _caller2 = scene_2) -> Node:
	var cardToAdd
	cardToAdd = preload("res://Card/Card_test.tscn").instantiate() as card
	cardToAdd.initCard(cardName)
	
	cardToAdd.global_position = self.global_position
	cardToAdd.z_index = 100
	cardDeck.add_card(cardToAdd, _isOppoent)
	
	return cardToAdd
