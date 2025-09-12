extends Panel


@onready var desktop: Control = $desktop
@onready var desktops: HBoxContainer = $ScrollContainer/desktops



func _process(delta: float) -> void:
	if desktop.get_child_count() != 0:
		var children = desktop.get_children()
		sort_nodes_by_position(children)
		
func sort_nodes_by_position(children):
	for i in range(children.size()):
		if children[i].cardCurrentState:
			children[i].z_index = i
			desktop.move_child(children[i],i)

func sort_by_position(a,b):
	return a.position.x < b.position.x
	
func add_card(cardToAdd) -> void:
	var index = cardToAdd.z_index
	var desktop = preload("res://desktop/desktop.tscn").instantiate()
	desktops.add_child(desktop)
	
	if index <= desktops.get_child_count():
		desktops.move_child(desktop,index)
	else:
		desktops.move_child(desktop, -1)
	var global_poi = cardToAdd.global_position
	
	if cardToAdd.get_parent():
		cardToAdd.get_parent().remove_child(cardToAdd)
	desktop.add_child(cardToAdd)
	cardToAdd.global_position = global_poi
	
	cardToAdd.preDeck = self
	
	cardToAdd.cardCurrentState = cardToAdd.cardState.following
	
	
	
