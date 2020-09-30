extends Node2D

onready var interface : CanvasLayer = get_parent()

func _process(_delta):
    make_interface_centered()
    
func make_interface_centered():
    var internal_x = ProjectSettings.get_setting("display/window/size/width")
    var effective_x = interface.get_effective_screen_size().x
    global_position.x = 0.5*(effective_x - internal_x)
