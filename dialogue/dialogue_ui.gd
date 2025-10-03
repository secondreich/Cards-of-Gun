extends Control

@export_group("UI")
@export var leftAvatar : TextureRect
@export var speaker : RichTextLabel
@export var content : RichTextLabel
@export var rightAvatar : TextureRect

@export_group("对话组")
@export var mainDialogues : dialogueGroup 

@export_group("打字速度，X个/秒")
@export var text_speed = 10.0

@export_group("音效")
@export var type_sound: AudioStreamPlayer  
@export var sound_interval = 0.15  

var dialogue_index = 0
var is_typing = false 
var current_tween: Tween
var type_sound_timer: Timer  

func _ready():
	
	type_sound_timer = Timer.new()
	type_sound_timer.wait_time = sound_interval
	type_sound_timer.one_shot = false
	type_sound_timer.timeout.connect(_play_type_sound)
	add_child(type_sound_timer)
	add_next_dialogue()


func add_next_dialogue() -> void:
	var now_dialogue = mainDialogues.dialogueGroup[dialogue_index]
	#填充对话内容
	speaker.visible_ratio = 0
	content.visible_ratio = 0 
	speaker.text = now_dialogue.speaker
	content.text = now_dialogue.content

	var speaker_duration = speaker.text.length() / text_speed
	var content_duration = content.text.length() / text_speed
	
	# 创建tween并并行执行两个动画
	var tween = create_tween()
	current_tween = tween
	is_typing = true
	tween.set_parallel(true)  # 设置为并行模式
	tween.tween_property(speaker, "visible_ratio", 1, speaker_duration)
	tween.tween_property(content, "visible_ratio", 1, content_duration)
	# 设置打字状态
	is_typing = true
	current_tween.finished.connect(_on_typing_finished)
	
	_update_sound_interval()
	
	# 开始播放打字音效
	type_sound_timer.start()
	
	if now_dialogue.avatarPosition == dialogue.avatarEnum.left:
		leftAvatar.texture = now_dialogue.avatar
	elif now_dialogue.avatarPosition == dialogue.avatarEnum.right:
		rightAvatar.texture = now_dialogue.avatar
	
	if now_dialogue.uiPosition == dialogue.uiEnum.up:
		self.position.y = 0
		print(self.position.y )
	elif now_dialogue.uiPosition == dialogue.uiEnum.mid:
		self.position.y = (get_viewport_rect().size.y - leftAvatar.get_rect().size.y ) /2
		print(self.position.y )
	elif now_dialogue.uiPosition == dialogue.uiEnum.bottle:
		self.position.y = (get_viewport_rect().size.y - leftAvatar.get_rect().size.y ) 
		print(self.position.y )


func _on_click_to_next_dialogue():
	# 如果正在打字，立即完成当前打字效果
	if is_typing:
		if current_tween:
			current_tween.kill()
		speaker.visible_ratio = 1.0
		content.visible_ratio = 1.0
		is_typing = false
		# 停止打字音效
		type_sound_timer.stop()
		return
	else:
		dialogue_index += 1
		if dialogue_index < mainDialogues.dialogueGroup.size():
			add_next_dialogue()
		else:
			self.visible = false
			get_tree().change_scene_to_file("res://main.tscn")		

#播放音效
func _play_type_sound():
	if type_sound and type_sound.stream:
		type_sound.play()

# 停止打字音效
func _on_typing_finished():
	is_typing = false
	type_sound_timer.stop()

func _update_sound_interval():
	if type_sound_timer == null:
		return
	# 打字速度越快，音效播放频率越高
	var base_interval = sound_interval  # 基础间隔
	var min_interval = sound_interval * 0.75  # 最小间隔
	var max_interval = sound_interval * 1.5   # 最大间隔
	
	# 计算新的间隔（速度越快，间隔越短）
	var new_interval = base_interval * (10.0 / text_speed)
	new_interval = clamp(new_interval, min_interval, max_interval)
	
	type_sound_timer.wait_time = new_interval
