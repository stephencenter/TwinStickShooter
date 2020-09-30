extends Button

export var display_mode_id : int
onready var interface : CanvasLayer = get_tree().get_root().get_node("World/Interface")
onready var radio_sprite_on : Texture = load("res://Sprites/radio_on.png")
onready var radio_sprite_off : Texture = load("res://Sprites/radio_off.png")

func _process(_delta):
    update_button_icon()

func _pressed():
    interface.set_temp_setting("display_mode", display_mode_id)
        
func update_button_icon():
    if display_mode_id == interface.get_temp_setting("display_mode"):
        icon = radio_sprite_on
    else:
        icon = radio_sprite_off
