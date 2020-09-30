extends Button

onready var interface = get_tree().get_root().get_node("World/Interface")

func _pressed():
    interface.toggle_pause()
