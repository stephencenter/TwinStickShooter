extends OptionButton

onready var config = get_tree().get_root().get_node("Game/SettingsManager")

func _ready():
    add_item("16:9", 0)
    add_item("16:10", 1)
    add_item("4:3", 2)
    add_item("21:9", 3)
    
    select(config.get_setting("aspect_ratio"))

func _process(_delta):
    config.set_temp_setting("aspect_ratio", get_selected_id())