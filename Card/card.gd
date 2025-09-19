extends Control

class_name card

enum cardState{following, dragging, vfs}
@export var cardCurrentState = cardState.following
@export var follow_target : Node

var velocity = Vector2.ZERO
var damping = 0.25
var stiffness = 500

var whichDeckIn #检查卡组落点
var dup #渲染
var preDeck #之前的卡组
var pickButton 

var original_size: Vector2
var original_scale: Vector2
var original_z_index: int

@export var cardLabel : String
@export var cardName : String
@export var isPlurality: int
@export var cardInfo : Dictionary

@export var ZOOM_SCALE = 1.15  # 放大倍数
@export var ZOOM_DURATION = 0.2  # 放大动画时长

func _ready():
	original_scale = scale
	original_z_index = z_index
	original_size =size
	
	
func _process(delta: float) -> void:
	match cardCurrentState:
		cardState.dragging:
			var target_position = get_global_mouse_position() - size/4
			global_position = global_position.lerp(target_position, 0.4)
			#z_index = original_z_index
			
			var nodes = get_tree().get_nodes_in_group("卡组分组")
			var mouse_position = get_global_mouse_position()
			for node in nodes:
				if node.get_global_rect().has_point(mouse_position) && node.visible == true:
					whichDeckIn = node				
			
		cardState.following:
			if follow_target != null:
				#z_index = original_z_index
				var target_position = follow_target.global_position
				var displacement = target_position - global_position
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta
				
func _on_mouse_entered():
	if self.size == original_size:
		var tween = create_tween()
		tween.tween_property(self, "size", self.size * ZOOM_SCALE, ZOOM_DURATION / 2)
		
		
func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "size", self.size / ZOOM_SCALE, ZOOM_DURATION / 2)

func _on_button_button_down() -> void:
	#print("按钮按下，跟随目标", follow_target)
	cardCurrentState = cardState.dragging
	if follow_target != null:
		follow_target.queue_free()
	pass
	
func _on_button_button_up() -> void:
	#print("按钮松开，跟随目标", follow_target)
	cardCurrentState = cardState.following
	
	if whichDeckIn != null:
		whichDeckIn.add_card(self)
	else:
		preDeck.add_card(self)
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
	var imgPath = "res://image/"+ str(cardName)+".png"
	$Control/Card/CardImage.texture = load(imgPath)
	$Control/Card/CardName.text = cardInfo["display_name"]
	
