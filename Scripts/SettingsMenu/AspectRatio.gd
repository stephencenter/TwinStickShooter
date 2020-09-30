extends OptionButton

onready var interface = get_tree().get_root().get_node("World/Interface")

func _ready():
    add_item("16:9", 0)
    add_item("16:10", 1)
    add_item("4:3", 2)
    add_item("21:9", 3)
    
    select(interface.SETTINGS["aspect_ratio"])

func _process(_delta):
    interface.update_temp_settings("aspect_ratio", get_selected_id())
