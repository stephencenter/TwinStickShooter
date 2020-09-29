extends Node2D

const BULLET_TRAVEL_SPEED : float = 800.0
const BULLET_LIFESPAN : float = 3.0
const BULLET_DAMAGE : int = 1

onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox

var current_velocity : Vector2

func _ready():
    lifespan_timer.start(BULLET_LIFESPAN)

func _process(delta):
    global_position += current_velocity*delta
    attempt_damage_enemies()
    keep_alive_if_inbounds()
    
    if lifespan_timer.time_left == 0:
        self_destruct()

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
    var parent = get_parent()
    if parent != null:
        parent.remove_child(self)
