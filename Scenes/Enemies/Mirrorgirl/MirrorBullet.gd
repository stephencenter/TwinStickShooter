extends Node2D

const BULLET_TRAVEL_SPEED : float = 800.0
const BULLET_LIFESPAN : float = 0.1
const BULLET_DAMAGE : int = 1

onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox
onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = get_tree().get_root().get_node("Game/Interface")

var current_velocity : Vector2

func _ready():
    lifespan_timer.start(BULLET_LIFESPAN)

func _process(delta):            
    process_movement(delta)
    attempt_damage_player()
    manage_lifespan_timer()

func process_movement(delta):
    var player_pos = the_game.get_player_global_position()
    current_velocity = (player_pos - global_position).normalized()*BULLET_TRAVEL_SPEED
    global_position += current_velocity*delta
    
func attempt_damage_player():        
    for area in hitbox.get_overlapping_areas():
        var entity = area.get_parent()
        if entity == the_game.get_player():
            entity.take_damage_from_enemy(BULLET_DAMAGE)
            queue_free()
        
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(BULLET_LIFESPAN)
    
    if lifespan_timer.time_left == 0:
        queue_free()
