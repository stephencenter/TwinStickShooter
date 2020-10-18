extends Node2D

const LASER_TRAVEL_SPEED : float = 400.0
const LASER_LIFESPAN : float = 0.5
const LASER_DAMAGE : int = 1

onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox
onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = the_game.get_node("Interface")

var current_velocity : Vector2

func _ready():
    lifespan_timer.start(LASER_LIFESPAN)

func _process(delta):      
    process_movement(delta) 
    attempt_damage_player()
    manage_lifespan_timer()

func process_movement(delta):        
    global_position += current_velocity*delta
    
func attempt_damage_player():
    if !the_game.get_player().is_alive():
        return
        
    for area in hitbox.get_overlapping_areas():
        var entity = area.get_parent()
        if entity == the_game.get_player():
            entity.take_damage_from_enemy(LASER_DAMAGE)
            
func set_laser_velocity(direction : Vector2):
    direction = direction.normalized()
    rotation = direction.angle()
    current_velocity = direction*LASER_TRAVEL_SPEED
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
    
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(LASER_LIFESPAN)
    
    if lifespan_timer.time_left == 0:
        queue_free()
