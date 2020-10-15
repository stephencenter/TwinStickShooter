extends "res://Scenes/Enemies/Enemy.gd"

const MIRROR_MOVE_SPEED : float = 300.0
const MIRROR_ORBIT_DISTANCE : float = 200.0
const MIRROR_ORBIT_DEADZONE : float = 2.0
const MIRROR_ORBIT_DURATION : float = 12.0
var attached = false

onready var bullet_scene = load("res://Scenes/Enemies/MirrorBullet.tscn")
onready var reflector = $Reflector
onready var orbit_timer = $OrbitTimer
    
func _process(_delta):
    reflect_bullets()

func take_damage_from_player(_value):
    return

func process_movement(var delta : float):
    var player_pos = the_world.get_player().global_position
    var variance = abs(player_pos.distance_to(global_position) - MIRROR_ORBIT_DISTANCE)
    var target_vec = (global_position - player_pos).normalized()
    var target_point : Vector2
    
    if variance < MIRROR_ORBIT_DEADZONE and !attached:
        attached = true
        orbit_timer.start(MIRROR_ORBIT_DURATION)
        
    if attached:
        if orbit_timer.time_left == 0:
            target_point = get_closest_corner()
            
        else:
            global_position = target_vec*MIRROR_ORBIT_DISTANCE + player_pos
            var c_angle = get_current_angle()
            target_point = global_position + Vector2(-c_angle.y, c_angle.x)
        
    else:
        target_point = target_vec*MIRROR_ORBIT_DISTANCE + player_pos

    current_velocity = (target_point - global_position).normalized()*MIRROR_MOVE_SPEED
    global_position += current_velocity*delta

func get_current_angle() -> Vector2:
    var the_player = the_world.get_player()
    return (global_position - the_player.global_position).normalized()

func reflect_bullets():
    var areas = reflector.get_overlapping_areas()
    if areas.empty():
        return
        
    areas[0].get_parent().queue_free()
    var bullet_obj = bullet_scene.instance()
    get_parent().add_child(bullet_obj)
    bullet_obj.global_position = global_position    

func get_closest_corner() -> Vector2:
    var screen_size = get_viewport().get_visible_rect().size
    var world_rect = interface.get_visible_world_position()
    var margin = 0.1
    var chosen_corner = Vector2()
    
    if global_position.x < world_rect[0].x + screen_size.x/2:
        chosen_corner.x = world_rect[0].x*(1 - margin)
    else:
        chosen_corner.x = world_rect[1].x*(1 + margin)
        
    if global_position.y < world_rect[0].y + screen_size.y/2:
        chosen_corner.y = world_rect[0].y*(1 - margin)
    else:
        chosen_corner.y = world_rect[1].y*(1 + margin)

    return chosen_corner
