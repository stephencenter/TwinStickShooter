extends "res://Scenes/Enemies/Enemy.gd"

const MIRROR_MOVE_SPEED : float = 300.0
const MIRROR_ORBIT_DISTANCE : float = 200.0
const MIRROR_ORBIT_DEADZONE : float = 2.0
const MIRROR_ORBIT_DURATION : float = 12.0
const MIRROR_REFLECTION_CD : float = 1.5
var attached = false

onready var bullet_scene = load("res://Scenes/Enemies/Mirrorgirl/MirrorBullet.tscn")
onready var reflector = $Reflector
onready var orbit_timer = $OrbitTimer
onready var reflect_timer = $ReflectTimer
    
func _process(_delta):
    reflect_bullets()

func take_damage_from_player(_value):
    return

func process_movement(var delta : float):
    var player_pos = the_game.get_player_global_position()
    var variance = abs(player_pos.distance_to(global_position) - MIRROR_ORBIT_DISTANCE)
    var target_vec = (global_position - player_pos).normalized()
    var target_point : Vector2
    
    if variance < MIRROR_ORBIT_DEADZONE and !attached:
        attached = true
        orbit_timer.start(MIRROR_ORBIT_DURATION)
        
    if attached and orbit_timer.time_left > 0:
        global_position = target_vec*MIRROR_ORBIT_DISTANCE + player_pos
        var c_angle = get_current_angle()
        target_point = global_position + Vector2(-c_angle.y, c_angle.x)
    
    else:
        target_point = target_vec*MIRROR_ORBIT_DISTANCE + player_pos
    
    if orbit_timer.time_left > 0 or !attached:
        current_velocity = (target_point - global_position).normalized()*MIRROR_MOVE_SPEED
    
    global_position += current_velocity*delta

func get_current_angle() -> Vector2:
    return (global_position - the_game.get_player_global_position()).normalized()

func reflect_bullets():
    if reflect_timer.time_left > 0:
        return
        
    var areas = reflector.get_overlapping_areas()
    if areas.empty():
        return
        
    areas[0].get_parent().queue_free()
    var bullet_obj = bullet_scene.instance()
    get_parent().add_child(bullet_obj)
    bullet_obj.global_position = global_position
    reflect_timer.start(MIRROR_REFLECTION_CD)