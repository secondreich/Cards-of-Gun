extends Node2D

@export var scene_1 : Node
@export var scene_2 : Node

@export var MaxHandCard = 7

@export var siteItems : Dictionary

func _ready():
	$HandCardPer.max_value = MaxHandCard
	print("ready")
	print($HandCardPer.max_value)

func add_new_hand_card(cardName, cardDeck , _caller = scene_1) -> Node:
	#print("发手牌：" + str(cardName))
	var cardClass = BaseCard.infosDic[cardName]["card_label"]
	#print("卡牌的类型是%s:"%cardClass)
	var cardToAdd
	cardToAdd = preload("res://Card/Card.tscn").instantiate() as card
	
	cardToAdd.initCard(cardName)
	
	cardToAdd.global_position = self.global_position
	cardToAdd.z_index = 100
	cardDeck.add_card(cardToAdd)
	
	return cardToAdd


func get_cards():
	var num_cards = 3
	var total_weight = get_total_weight(siteItems)
	var selected_cards = []
	for i in range(num_cards):
		if(scene_1.card_total_num < MaxHandCard):
			var random_num = randi() % total_weight
			var cumulative_weight = 0
			for c in siteItems.keys():
				cumulative_weight += siteItems[c]
				if random_num < cumulative_weight:
					selected_cards.append(c)
					scene_1.card_total_num += 1
					
					print(selected_cards)
					#print("注入select数组")
					break
					
		else:
			print("手牌达到上限")
			break
	for c in selected_cards:
		await get_tree().create_timer(0.1,1).timeout
		add_new_hand_card(c, scene_1)
	update_data()
		
func get_total_weight(card_dict):
	var total_weight = 0
	for weight in card_dict.values():
		total_weight += weight
	return total_weight


func update_data() -> void:
	$HandCardPer.value = scene_1.card_total_num
	$PlayerProperty/PlayerHandCard.text = "手牌：     "+ str(scene_1.card_total_num) + " / " + str(MaxHandCard)
	
	
