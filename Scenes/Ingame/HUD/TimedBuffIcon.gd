extends Control

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

onready var timer_bar : Control = $TimeRemaining
onready var icon_container = get_parent()
onready var POWERUP_SPRITEMAP : Dictionary = {
    0: load("res://Sprites/powerup_surround_icon.png"),
    1: load("res://Sprites/powerup_barrier_icon.png"),
    2: load("res://Sprites/powerup_multishot_icon.png"),
    3: load("res://Sprites/powerup_homing_icon.png")
}
    
var powerup_id : int = 2
var player : Node2D

func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    update_timer()
    update_icon_position()

func update_timer():
    if player == null:
        player = the_game.get_player()
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
    for icon in icon_container.get_children():
        if icon == self:
            break
        
        index += 1
    
    var height = $Template.rect_size.y*rect_scale.y
    rect_position.y = -index*(height + 10)
