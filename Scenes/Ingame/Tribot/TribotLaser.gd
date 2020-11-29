extends Node2D

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = get_tree().get_root().get_node("Game/Interface")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

const LASER_TRAVEL_SPEED : float = 400.0
const LASER_LIFESPAN : float = 0.5
const LASER_DAMAGE : int = 1

onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var lifespan_timer = timer_class.new([the_game.GameState.INGAME], the_game)
onready var hitbox : Area2D = $Hitbox
var current_velocity : Vector2

func _ready():
    lifespan_timer.start(LASER_LIFESPAN)
    
func _process(delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
              
    process_movement(delta) 
    attempt_damage_player()
    manage_lifespan_timer()

func process_movement(delta):        
    global_position += current_velocity*delta
    
func attempt_damage_player():
    if not the_game.get_player().is_alive():
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
    
    if lifespan_timer.is_stopped():
        queue_free()
