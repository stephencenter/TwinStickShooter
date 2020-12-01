extends Node2D

const PROJECTILE_LIFESPAN = 0.5
var PROJECTILE_DAMAGE : int
var PROJECTILE_TRAVEL_SPEED : float
var PROJECTILE_OWNER : Node2D
var PROJECTILE_TARGET : Node2D
var PIERCES_ENTITIES : bool
var current_velocity : Vector2

func _ready():
    pass

func _process(delta):
    process_movement(delta)
    attempt_damage_entities()

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
