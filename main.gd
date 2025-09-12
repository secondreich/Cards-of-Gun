extends Node2D

@export var scene_1 : Node
@export var scene_2 : Node

@export var MaxHandCard : int

@export var siteItems : Dictionary

func add_new_hand_card(cardName,desktop, caller = scene_1) -> Node:
	print("发手牌：" + str(cardName))
	var my_card_instance = baseCard.new()
	var cardClass = my_card_instance.infosDic[cardName]["base_name"]
	print("卡牌的类型是%s:"%cardClass)
	var cardToAdd
	cardToAdd = preload("res://Card/Card.tscn").instantiate() as card
	
	cardToAdd.initCard(cardName)
	
	cardToAdd.global_position = caller.global_position
	cardToAdd.z_index = 100
	desktop.add_card(cardToAdd)
	
	return cardToAdd


func get_cards():
	
	var num_cards = 3
	var selected_cards = []
	for i in range(num_cards):
		print("card added")
		for c in siteItems.keys():
			selected_cards.append(c)
			print("card item")
		
	for c in selected_cards:
		await get_tree().create_timer(0,1).timeout
		add_new_hand_card(c, scene_1)
		
