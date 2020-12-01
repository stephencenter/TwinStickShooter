extends Node2D

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var lifespan_timer = timer_class.new(ACTIVE_STATES, the_game)

const PROJECTILE_LIFESPAN = 0.5
var PROJECTILE_DAMAGE : int
var PROJECTILE_TRAVEL_SPEED : float
var PROJECTILE_OWNER : Node2D
var PROJECTILE_TARGET : Node2D
var PIERCES_ENTITIES : bool
var current_velocity : Vector2

func _ready():
    lifespan_timer.start(PROJECTILE_LIFESPAN)

func _process(delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    process_movement(delta)
    attempt_damage_entities()
    manage_lifespan_timer()
        
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(PROJECTILE_LIFESPAN)
    
    if lifespan_timer.is_stopped():
        queue_free()

func process_movement(delta):
    if PROJECTILE_TARGET != null:
        var target_direction = PROJECTILE_TARGET.global_position - global_position
        current_velocity = (current_velocity + target_direction).normalized()*PROJECTILE_TRAVEL_SPEED
        
    global_position += current_velocity*delta

func set_projectile_owner(new_owner : Node2D):
    PROJECTILE_OWNER = new_owner
    
func set_projectile_target(new_target : Node2D):
    PROJECTILE_TARGET = new_target
    
func set_initial_velocity(direction : Vector2):
    direction = direction.normalized()
    rotation = direction.angle()
    current_velocity = direction*PROJECTILE_TRAVEL_SPEED
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
    
func attempt_damage_entities():        
    for area in $Hitbox.get_overlapping_areas():
        area.get_parent().take_damage(PROJECTILE_DAMAGE)
        
        if not PIERCES_ENTITIES:
            queue_free()
            return
