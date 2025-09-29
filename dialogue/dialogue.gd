extends Resource

class_name dialogue

@export var speaker : String
@export var content : String
@export var avatar : Texture
#头像位置可以在左右或者无
enum avatarEnum {left, right, noAcatar}
enum uiEnum {up, mid, bottle}

@export var avatarPosition = avatarEnum.noAcatar
@export var uiPosition = uiEnum.bottle
