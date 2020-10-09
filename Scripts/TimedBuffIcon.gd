extends Control

var powerup_id : int = 2
var player : Node2D
onready var timer_bar : Control = $TimeRemaining
onready var the_world = get_tree().get_root().get_node("Game")
onready var list_of_icons = get_parent()
onready var POWERUP_SPRITEMAP : Dictionary = {
    0: load("res://Sprites/powerup_surround_icon.png"),
    1: load("res://Sprites/powerup_barrier_icon.png"),
    2: load("res://Sprites/powerup_multishot_icon.png"),
    3: load("res://Sprites/powerup_homing_icon.png")
}
    
func _process(_delta):
    update_timer()
    update_icon_position()

func update_timer():
    if !the_world.is_player_alive():
        player = null
        return
    
    if player == null:
        player = the_world.get_player()
        return
    
    if $Icon.texture == null:
        $Icon.texture = POWERUP_SPRITEMAP[powerup_id]
        
    var full_time = player.POWERUP_DURATION
    var time_remaining = player.get_powerup_time_remaining(powerup_id)
    
    if time_remaining == 0:
        queue_free()
        return

    timer_bar.rect_scale.x = time_remaining/full_time
    
func update_icon_position():
    var index = 0
    for icon in list_of_icons.get_children():
        if icon == self:
            break
        
        index += 1
    
    var height = $Template.rect_size.y*rect_scale.y
    rect_position.y = -index*(height + 10)
