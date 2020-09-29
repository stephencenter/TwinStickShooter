extends Node2D

const BULLET_TRAVEL_SPEED : float = 800.0
const BULLET_LIFESPAN : float = 3.0
const BULLET_DAMAGE : int = 1

onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox
onready var the_world = get_parent().get_parent()
onready var homing_radius : Area2D = $HomingRadius

var current_velocity : Vector2

func _ready():
    lifespan_timer.start(BULLET_LIFESPAN)

func _process(delta):
    if is_inside_tree():
        keep_alive_if_inbounds()
        process_movement(delta)
        attempt_damage_enemies()
        
        if lifespan_timer.time_left == 0:
            self_destruct()

func process_movement(delta):
    var player = the_world.get_player()
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
        self_destruct()
        
func keep_alive_if_inbounds():
    var screen_size_x = ProjectSettings.get_setting("display/window/size/width")
    var screen_size_y = ProjectSettings.get_setting("display/window/size/height")
    
    if global_position.x > 0 and global_position.x < screen_size_x:
        if global_position.y > 0 and global_position.y < screen_size_y:
            lifespan_timer.start(BULLET_LIFESPAN)
        
func self_destruct():
    if is_inside_tree():
        get_parent().remove_child(self)
