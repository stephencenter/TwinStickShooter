extends Control

func _ready():
    pass

func _process(_delta):
    make_interface_centered()
    
func make_interface_centered():
    var internal_x = ProjectSettings.get_setting("display/window/size/width")
    var effective_x = get_effective_screen_size().x
    rect_position.x = 0.5*(effective_x - internal_x)

func get_effective_screen_size() -> Vector2:
    var internal_x = ProjectSettings.get_setting("display/window/size/width")
    var internal_y = ProjectSettings.get_setting("display/window/size/height")
    var visual = get_viewport().size
    
    var internal_aspect = float(internal_x)/float(internal_y)
    var visual_aspect = visual.x/visual.y
    var aspect_ratio = visual_aspect/internal_aspect
    
    var effective_x = max(aspect_ratio*internal_x, internal_x)
    var effective_y = max(internal_y/aspect_ratio, internal_y)
    return Vector2(effective_x, effective_y)
    
