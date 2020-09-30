extends Button

onready var interface = get_tree().get_root().get_node("World/Interface")
onready var success_timer = get_parent().get_node("SuccessTimer")
onready var success_label = get_parent().get_node("SuccessLabel")

func _process(_delta):
    if success_timer.time_left == 0 or !get_tree().paused:
        success_label.set_text("")
    
func _pressed():
    interface.apply_temp_settings()
    interface.previous_ratio_id = -1
    interface.previous_reso_id = -1
    success_label.set_text("Settings applied successfully!")
    success_timer.start(3)
