extends "res://Scenes/Ingame/Enemy.gd"

const MIRROR_MOVE_SPEED : float = 300.0
const MIRROR_ORBIT_DISTANCE : float = 200.0
const MIRROR_ORBIT_DEADZONE : float = 2.0
const MIRROR_ORBIT_DURATION : float = 12.0
const MIRROR_REFLECTION_CD : float = 1.5
var attached = false

onready var bullet_scene = load("res://Scenes/Ingame/Mirrorgirl/MirrorBullet.tscn")
onready var reflector = $Reflector
onready var orbit_timer = timer_class.new([the_game.GameState.INGAME], the_game)
onready var reflect_timer = timer_class.new([the_game.GameState.INGAME], the_game)
    
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    reflect_bullets()

func take_damage(_value):
    return

func process_movement(var delta : float):
    var player_pos = the_game.get_player_global_position()
    var variance = abs(player_pos.distance_to(global_position) - MIRROR_ORBIT_DISTANCE)
    var target_vec = (global_position - player_pos).normalized()
    var target_point : Vector2
    
    if variance < MIRROR_ORBIT_DEADZONE and not attached:
        attached = true
        orbit_timer.start(MIRROR_ORBIT_DURATION)
        
    if attached and not orbit_timer.is_stopped():
        global_position = target_vec*MIRROR_ORBIT_DISTANCE + player_pos
        var c_angle = get_current_angle()
        target_point = global_position + Vector2(-c_angle.y, c_angle.x)
    
    else:
        target_point = target_vec*MIRROR_ORBIT_DISTANCE + player_pos
    
    if not orbit_timer.is_stopped() or not attached:
        current_velocity = (target_point - global_position).normalized()*MIRROR_MOVE_SPEED
    
    global_position += current_velocity*delta

func get_current_angle() -> Vector2:
    return (global_position - the_game.get_player_global_position()).normalized()

func reflect_bullets():
    if not reflect_timer.is_stopped():
        return
        
    var areas = reflector.get_overlapping_areas()
    if areas.empty():
        return
        
    var old_bullet = areas[0].get_parent()
    var evil_bullet = bullet_scene.instance()
    get_parent().add_child(evil_bullet)
    evil_bullet.global_position = global_position
    evil_bullet.set_projectile_owner(self)
    evil_bullet.set_projectile_target(old_bullet.PROJECTILE_OWNER)
    reflect_timer.start(MIRROR_REFLECTION_CD)
