extends Node2D

const LASER_TRAVEL_SPEED : float = 400.0
const LASER_LIFESPAN : float = 5.0
const LASER_DAMAGE : int = 1

onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox
onready var the_world : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = the_world.get_node("Interface")

var current_velocity : Vector2
var counter = 0

func _ready():
    lifespan_timer.start(LASER_LIFESPAN)

func _process(delta):      
    process_movement(delta)  
    keep_alive_if_inbounds()
    attempt_damage_player()
    
    if lifespan_timer.time_left == 0:
        queue_free()

func process_movement(delta):        
    global_position += current_velocity*delta
    
func attempt_damage_player():
    if !the_world.is_player_alive():
        return
        
    for area in hitbox.get_overlapping_areas():
        var entity = area.get_parent()
        if entity == the_world.get_player():
            entity.take_damage_from_enemy(LASER_DAMAGE)
            
func set_laser_velocity(direction : Vector2):
    direction = direction.normalized()
    rotation = direction.angle()
    current_velocity = direction*LASER_TRAVEL_SPEED
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
        
func keep_alive_if_inbounds():
    var visible_pos =  interface.get_visible_world_position()
    var top_left = visible_pos[0]
    var bot_right = visible_pos[1]
    
    if global_position.x > top_left.x and global_position.x < bot_right.x:
        if global_position.y > top_left.y and global_position.y < bot_right.y:
            lifespan_timer.start(LASER_LIFESPAN)
