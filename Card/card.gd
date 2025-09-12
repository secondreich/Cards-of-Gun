extends Control


enum cardState{following, dragging}
@export var cardCurrentState = cardState.following
@export var follow_target : Node

var velocity = Vector2.ZERO
var damping = 0.20
var stiffness = 500


func _process(delta: float) -> void:
	match cardCurrentState:
		cardState.dragging:
			#print("dragging")
			var target_position = get_global_mouse_position() - size/2
			global_position = global_position.lerp(target_position, 0.4)
		cardState.following:
			if follow_target != null:
				#print("following")
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
