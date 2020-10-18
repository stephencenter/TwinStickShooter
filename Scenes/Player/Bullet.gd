extends Node2D

const BULLET_TRAVEL_SPEED : float = 800.0
const BULLET_LIFESPAN : float = 0.5
const BULLET_DAMAGE : int = 1

onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox
onready var homing_radius : Area2D = $HomingRadius
onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = get_tree().get_root().get_node("Game/Interface")

var current_velocity : Vector2

func _ready():
    lifespan_timer.start(BULLET_LIFESPAN)

func _process(delta):      
    process_movement(delta)
    attempt_damage_enemies()
    manage_lifespan_timer()

func process_movement(delta):
    var player = the_game.get_player()
    if player != null and player.has_powerup(3):
        var areas = homing_radius.get_overlapping_areas()
        var closest_enemy : Node2D
        var closest_distance : float = -1
        
        for area in areas:                
            var distance = global_position.distance_to(area.global_position)
            if distance < closest_distance or closest_distance < 0:
                closest_distance = distance
                closest_enemy = area.get_parent()
            
        if closest_enemy != null:
            var bullet_pos = global_position
            var enemy_pos = closest_enemy.global_position
            var pointing = (enemy_pos - bullet_pos)
            
            current_velocity = (current_velocity + pointing).normalized()
            current_velocity = current_velocity.normalized()*BULLET_TRAVEL_SPEED
            
    global_position += current_velocity*delta
    
func set_bullet_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*BULLET_TRAVEL_SPEED
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos

func attempt_damage_enemies():
    var areas = hitbox.get_overlapping_areas()
    if !areas.empty():
        var enemy = areas[0].get_parent()
        enemy.take_damage_from_player(BULLET_DAMAGE)
        queue_free()
        
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(BULLET_LIFESPAN)
    
    if lifespan_timer.time_left == 0:
        queue_free()
