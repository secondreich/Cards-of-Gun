extends Node2D

class_name main

@export var scene_1 : Node
@export var scene_2 : Node

@export var MaxHandCard = 7

@export var siteItems : Dictionary

#定义血量和上限
@export var playerMaxLife = 3 
@export var playerLife = 3

@export var oppoentrMaxLife = 3 
@export var oppoentLife = 3


@export var playerMaxAmmo = 3
@export var playerAmmo = 0

@export var oppoentMaxAmmo = 3
@export var oppoentAmmo = 0

var now_used_card 

func _ready() -> void:
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
	if checkVolley() == true:
		add_new_hand_card("volley" ,scene_1)
		
	
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
	#结算
	print(usedCards)
	if not usedCards.is_empty():
		checkResult(usedCards , usedCards)
	
	#消除卡牌
	for c in usedCards:
		c.cardCurrentState = c.cardState.del
		delCards +=1
	scene_1.card_total_num -= delCards

#检查伤害结算，返回各式：用户造成的伤害，用户弹药变化，对手造成的伤害，对手弹药变化
func checkResult(PlayerCards , OppoentCards):
	var playerDamage = 0
	var oppoentDamage = 0
	var playerLoad = 0
	var oppoentLoad = 0
	var playerType = PlayerCards[0].cardLabel
	var oppoentType = OppoentCards[0].cardLabel
	
	for c in PlayerCards:
		if c.cardLabel.find("volley") != -1 :
			playerDamage = playerMaxAmmo
			playerLoad -= playerMaxAmmo
			break
		elif c.cardLabel.find("attack") != -1 && oppoentType.find("volley") == -1:
			playerDamage += 1
			playerLoad -= 1
		elif c.cardLabel.find("load") != -1 && oppoentType.find("attack") == -1:
			playerLoad += 1
		elif c.cardLabel.find("avoid") != -1 && oppoentType.find("volley") == -1:
			oppoentDamage = 0
			
	for c in OppoentCards:
		if c.cardLabel.find("volley") != -1 :
			oppoentDamage = oppoentMaxAmmo
			oppoentLoad -= oppoentMaxAmmo
			break
		elif c.cardLabel.find("attack") != -1 && playerType.find("volley") == -1:
			oppoentDamage += 1
			oppoentLoad -= 1
		elif c.cardLabel.find("load") != -1 && playerType.find("attack") == -1:
			oppoentLoad += 1
		elif c.cardLabel.find("avoid") != -1 && playerType.find("volley") == -1:
			playerDamage = 0
	
	playerLife -= max(oppoentDamage - playerDamage, 0)
	oppoentLife -= max(playerDamage - oppoentDamage, 0)
	playerAmmo += playerLoad
	oppoentAmmo += oppoentLoad
	

#检查是否添加齐射牌
func checkVolley() -> bool:
	for c in $HandCards.cardDeck.get_children():
		if c.cardLabel.find("volley") != -1:
			return false
	if playerAmmo == playerMaxAmmo:
		return true
	return false
	
