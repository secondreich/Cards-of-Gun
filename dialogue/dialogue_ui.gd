extends Control

@export_group("UI")
@export var leftAvatar : TextureRect
@export var speaker : RichTextLabel
@export var content : RichTextLabel
@export var rightAvatar : TextureRect

@export_group("对话组")
@export var mainDialogues : dialogueGroup 

var dialogue_index = 0

func _ready():
	add_next_dialogue()


func add_next_dialogue() -> void:
	var now_dialogue = mainDialogues.dialogueGroup[dialogue_index]
	#填充对话内容
	speaker.text = now_dialogue.speaker
	content.text = now_dialogue.content
	if now_dialogue.avatarPosition == dialogue.avatarEnum.left:
		leftAvatar.texture = now_dialogue.avatar
	elif now_dialogue.avatarPosition == dialogue.avatarEnum.right:
		rightAvatar.texture = now_dialogue.avatar
	
	if now_dialogue.uiPosition == dialogue.uiEnum.up:
		pass
	elif now_dialogue.uiPosition == dialogue.uiEnum.mid:
		pass
	elif now_dialogue.uiPosition == dialogue.uiEnum.bottle:
		pass


func _on_click_to_next_dialogue():
	dialogue_index += 1
	if dialogue_index < mainDialogues.dialogueGroup.size():
		add_next_dialogue()
	else:
		self.visible = 0
		get_tree().change_scene_to_file("res://main.tscn")
		
