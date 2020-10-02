extends Control

onready var player : Node2D
onready var the_world = get_tree().get_root().get_node("World")
onready var remaining_bar : TextureRect = $CurrentHealth
onready var hbar_size : Vector2 = $Border.rect_size
onready var hp_label : Label = $HealthLabel

func _process(_delta):
    if !the_world.is_player_alive():
        player = null
        return
    
    if player == null:
        player = the_world.get_player()
        return
    
    if player.PLAYER_MAX_HEALTH == 1:
        visible = false
        return
        
    var current = player.current_health
    var maxim = player.PLAYER_MAX_HEALTH
    
    remaining_bar.rect_scale.x = float(current)/float(maxim)
    
    hp_label.set_text("%s/%s" % [current, maxim])
    hp_label.set_size(Vector2.ZERO)
    var label_size = hp_label.get_size()
    hp_label.rect_position.x = hbar_size.x/2 - (label_size.x/rect_scale.x)/2
    hp_label.rect_position.y = hbar_size.y/2 - (label_size.y/rect_scale.y)/2
