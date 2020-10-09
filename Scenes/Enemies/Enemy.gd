extends Node2D

var ENEMY_LIFESPAN : float
var ENEMY_MAX_HEALTH : int
var ENEMY_ATTACK_DAMAGE : int
var ENEMY_POINT_REWARD : int 
var current_health : int
var current_velocity : Vector2

onready var hitbox : Area2D = $Hitbox
onready var lifespan_timer : Timer = $LifespanTimer
onready var the_world : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = the_world.get_node("Interface")

func _ready():
    lifespan_timer.start(ENEMY_LIFESPAN)
    
func _process(delta):
    process_movement(delta)
    attempt_damage_player()
    keep_alive_if_inbounds()
    
    if lifespan_timer.time_left == 0:
        queue_free()

func process_movement(var _delta : float):
    pass
    
func take_damage_from_player(damage_amount : int):
    current_health -= damage_amount
    if current_health <= 0:
        the_world.reward_enemy_points(self)
        queue_free()

func attempt_damage_player():
    if !the_world.is_player_alive():
        return
        
    for area in hitbox.get_overlapping_areas():
        var entity = area.get_parent()
        if entity == the_world.get_player():
            entity.take_damage_from_enemy(ENEMY_ATTACK_DAMAGE)
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
    
func keep_alive_if_inbounds():
    var visible_pos =  interface.get_visible_world_position()
    var top_left = visible_pos[0]
    var bot_right = visible_pos[1]
    
    if global_position.x > top_left.x and global_position.x < bot_right.x:
        if global_position.y > top_left.y and global_position.y < bot_right.y:
            lifespan_timer.start(ENEMY_LIFESPAN)
