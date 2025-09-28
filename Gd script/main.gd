extends Node2D

class_name main

@export var scene_1 : Node
@export var scene_2 : Node

#定义血量和上限
@export var playerMaxLife = 3 
@export var playerLife = 3
@export var oppoentrMaxLife = 3 
@export var oppoentLife = 3

@export var playerMaxAmmo = 3
@export var playerAmmo = 0
@export var oppoentMaxAmmo = 3
@export var oppoentAmmo = 0

#当前使用的卡，检查复数打出机制
var now_used_card 

@export var playerDeck: Array = []
var discard_deck: Array = []

func _ready() -> void:
	$HandCardPer.max_value = 7
	$PlayerProperty/PlayerHandCard.text = "手牌：     " + str(scene_1.card_total_num) + " / " + str(7)
	$PlayerProperty/PlayerLife.text = "生命：     " + str(playerLife) + " / " + str(playerMaxLife)
	$PlayerProperty/PlayerAmmo.text = "弹匣:       " + str(playerAmmo)+ " / " + str(playerMaxAmmo)
	print("ready")
	
	

func _process(delta: float) -> void:
	var usedCards = $UsedCards.cardDeck.get_children()
	var handsCards = $HandCards.cardDeck.get_children()
	
	#判断是否下一轮
	#if scene_1.card_total_num < playerLife:
		#$DrawCard/Button.disabled = false
	#else:
		#$DrawCard/Button.disabled = true
	
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
	var cards_drawn = 0
	var selected_cards = []
	var index = 0
	while cards_drawn < num_cards:
		if not playerDeck.is_empty():
			# 正常抽牌
			index = randi_range(0, playerDeck.size() - 1)
			selected_cards.append(playerDeck[index])
			playerDeck.remove_at(index)
			cards_drawn += 1
		elif not discard_deck.is_empty():
			# 重置卡组
			playerDeck = discard_deck.duplicate()
			playerDeck.shuffle()
			discard_deck.clear()
			print("卡组重置并洗牌")
		else:
			# 无牌可抽
			print("卡组中没有任何卡牌，无法再发牌了")
			break
		
	for c in selected_cards:
		scene_1.card_total_num += 1
		await get_tree().create_timer(0.1,1).timeout
		add_new_hand_card(c, scene_1)
	if checkVolley() == true:
		add_new_hand_card("volley" ,scene_1)

func get_oppoent_cards():
	var num_cards = 1
	var oppoentDeck = get_oppoent_deck()
	var selected_cards
	var index = randi_range(0,  oppoentDeck.size() - 1)
	selected_cards = oppoentDeck[index]
	for i in range(num_cards):
		await get_tree().create_timer(0.1,1).timeout
		add_new_hand_card(selected_cards, scene_2)

#更新数据
func update_data() -> void:
	$HandCardPer.value = scene_1.card_total_num
	$PlayerProperty/PlayerHandCard.text = "手牌：     " + str(scene_1.card_total_num) + " / " + str(7)
	$PlayerProperty/PlayerLife.text = "生命：     " + str(playerLife) + " / " + str(playerMaxLife)
	$PlayerProperty/PlayerAmmo.text = "弹匣:       " + str(playerAmmo)+ " / " + str(playerMaxAmmo)
	
#下一回合
func next_turn() -> void:
	var usedCards = $UsedCards.cardDeck.get_children()
	var oppoentCards = $OppoentCards.cardDeck.get_children()
	var delCards = 0
	#结算

	if not usedCards.is_empty():
		checkResult(usedCards , oppoentCards)
	
	#消除卡牌
	for c in usedCards:
		c.cardCurrentState = c.cardState.del
		
		#在弃牌堆中加入打出的卡，再从使用栏中将其删掉
		discard_deck.append(c.cardName)
		delCards +=1
	scene_1.card_total_num -= delCards
	
	#发新的牌
	for c in oppoentCards:
		c.cardCurrentState = c.cardState.del
	get_oppoent_cards()
	
	
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

func get_oppoent_deck() -> Array:
	var oppoentCards = ["shoot", "avoid", "load"]
	if oppoentAmmo == oppoentMaxAmmo:
		return ["volley"]
	if playerAmmo == 0:
		oppoentCards.filter(func(x): return x != "avoid")
	if oppoentAmmo == 0:
		oppoentCards.filter(func(x): return x != "shoot")
	return oppoentCards
