extends Node2D

@export var scene_1 : Node
@export var scene_2 : Node

@export var MaxHandCard = 7

@export var siteItems : Dictionary

#定义玩家血量和上限
@export var playerMaxLife = 3 
@export var playerLife = 3

@export var playerMaxAmmo = 3
@export var playerAmmo = 0

var now_used_card 

func _ready():
	$HandCardPer.max_value = MaxHandCard
	$PlayerProperty/PlayerHandCard.text = "手牌：     " + str(scene_1.card_total_num) + " / " + str(MaxHandCard)
	$PlayerProperty/PlayerLife.text = "生命：     " + str(playerLife) + " / " + str(playerMaxLife)
	$PlayerProperty/PlayerAmmo.text = "弹匣:       " + str(playerAmmo)+ " / " + str(playerMaxAmmo)
	print("ready")
	

func _process(delta: float) -> void:
	var usedCards = $UsedCards.cardDeck.get_children()
	var handsCards = $HandCards.cardDeck.get_children()
	
	#判断是否下一轮
	if scene_1.card_total_num < playerLife:
		$DrawCard/Button.disabled = false
	else:
		$DrawCard/Button.disabled = true
	
	#检查复数牌的打出机制
	if not usedCards.is_empty():  
		now_used_card = usedCards[0].cardLabel
	else:
		now_used_card = null
	if not handsCards.is_empty():
		for c in handsCards:
			if (now_used_card != null && c.cardLabel != now_used_card) || (now_used_card != null && c.isPlurality == 0):
				c.pickButton.disabled = true
			else:
				c.pickButton.disabled = false
	
	update_data()
	
#下一轮次，发牌
func add_new_hand_card(cardName, cardDeck , _caller = scene_1,  _caller2 = scene_2) -> Node:
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
		add_new_hand_card(c, scene_2)
	
func get_total_weight(card_dict):
	var total_weight = 0
	for weight in card_dict.values():
		total_weight += weight
	return total_weight

#更新数据
func update_data() -> void:
	$HandCardPer.value = scene_1.card_total_num
	$PlayerProperty/PlayerHandCard.text = "手牌：     " + str(scene_1.card_total_num) + " / " + str(MaxHandCard)
	$PlayerProperty/PlayerLife.text = "生命：     " + str(playerLife) + " / " + str(playerMaxLife)
	$PlayerProperty/PlayerAmmo.text = "弹匣:       " + str(playerAmmo)+ " / " + str(playerMaxAmmo)
	
#下一回合
func next_turn() -> void:
	var usedCards = $UsedCards.cardDeck.get_children()
	var delCards = 0
	for c in usedCards:
		c.cardCurrentState = c.cardState.del
		delCards +=1
	scene_1.card_total_num -= delCards
	
