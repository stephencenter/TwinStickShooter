extends OptionButton

var current_aspect_ratio : int = -1
onready var interface = get_tree().get_root().get_node("World/Interface")

const RESOLUTION_LIST : Dictionary = {
    0: [[1280, 720], [1366, 768], [1600, 900], [1920, 1080], [2560, 1440], [3840, 2160]],
    1: [[1152, 720], [1440, 900], [1680, 1050], [1920, 1200]],
    2: [[800, 600], [960, 720], [1024, 768], [1200, 900], [1280, 960], [1440, 1080], [1600, 1200]],
    3: [[1920, 800], [2560, 1080], [3440, 1440], [5120, 2160]]
}

func _ready():
    var ratio = get_current_aspect_ratio()
    if ratio != current_aspect_ratio:
        current_aspect_ratio = ratio
        repopulate_resolution_list()
        
    select(interface.SETTINGS["resolution_id"])
    
func _process(_delta):
    var ratio = get_current_aspect_ratio()
    if ratio != current_aspect_ratio:
        current_aspect_ratio = ratio
        repopulate_resolution_list()
    
    var selected_resolution = RESOLUTION_LIST[current_aspect_ratio][get_selected_id()]
    interface.update_temp_settings("resolution_x", selected_resolution[0])
    interface.update_temp_settings("resolution_y", selected_resolution[1])

func repopulate_resolution_list():
    clear()
    
    var screen_size = OS.get_screen_size()
    var index = 0
    for reso in RESOLUTION_LIST[current_aspect_ratio]:
        if !(reso[0] > screen_size.x or reso[1] > screen_size.y):
            add_item("%sx%s" % [reso[0], reso[1]], index)
            
        index += 1

func update_current_aspect_ratio():
    if interface.temp_settings.has("aspect_ratio"):
        current_aspect_ratio = interface.temp_settings["aspect_ratio"]
    else:
        current_aspect_ratio = interface.SETTINGS["aspect_ratio"]

func get_current_aspect_ratio():
    if interface.temp_settings.has("aspect_ratio"):
        return interface.temp_settings["aspect_ratio"]
    else:
        return interface.SETTINGS["aspect_ratio"]
    
