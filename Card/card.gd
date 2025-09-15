extends Control

class_name card

enum cardState{following, dragging}
@export var cardCurrentState = cardState.following
@export var follow_target : Node

var velocity = Vector2.ZERO
var damping = 0.25
var stiffness = 500

var preDeck
var pickButton 

@export var cardLabel : String
@export var cardName : String
@export var isPlurality: int
@export var cardInfo : Dictionary

func _process(delta: float) -> void:
	match cardCurrentState:
		cardState.dragging:
			var target_position = get_global_mouse_position() - size/2
			global_position = global_position.lerp(target_position, 0.4)
		cardState.following:
			if follow_target != null:
				var target_position = follow_target.global_position
				var displacement = target_position - global_position
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta
			
func _on_button_button_down() -> void:
	#print("按钮按下，跟随目标", follow_target)
	cardCurrentState = cardState.dragging
	pass
	
func _on_button_button_up() -> void:
	#print("按钮松开，跟随目标", follow_target)
	cardCurrentState = cardState.following
	pass
	
func initCard(Nm) -> void:
	cardInfo = BaseCard.infosDic[Nm]
	cardLabel = cardInfo["card_label"]
	cardName = cardInfo["base_name"]
	isPlurality = int(cardInfo["is_plurality"])
	cardCurrentState = cardState.following
	drawCard()
	
func drawCard():
	#print("draw completed")
	#pickButton = $Button
	var imgPath = "res://icon.svg"
	$Control/Card/CardImage.texture = load(imgPath)
	$Control/Card/CardName.text = cardInfo["display_name"]
	
