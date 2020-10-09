extends "res://Scenes/Enemies/Enemy.gd"

const TRIBOT_MAX_SPEED : float = 80.0
const LASER_COOLDOWN_LONG : float = 3.0
const LASER_COOLDOWN_SHORT : float = 0.35
const NUM_LASERS : int = 3
onready var laser_scene = load("res://Scenes/Enemies/TribotLaser.tscn")
onready var long_timer = $LaserTimerLong
onready var short_timer = $LaserTimerShort

var remaining_lasers = 0

func _ready():
    ENEMY_MAX_HEALTH = 6
    ENEMY_ATTACK_DAMAGE = 1
    ENEMY_POINT_REWARD = 3000
    current_health = ENEMY_MAX_HEALTH

func _process(_delta):
    if !the_world.is_player_alive():
        return
        
    if long_timer.time_left == 0:
        remaining_lasers = NUM_LASERS
        long_timer.start(LASER_COOLDOWN_LONG)
    
    if short_timer.time_left == 0 and remaining_lasers > 0:
        fire_laser()
        remaining_lasers -= 1
        short_timer.start(LASER_COOLDOWN_SHORT)
        
func process_movement(var delta : float):
    global_position += current_velocity*delta

func fire_laser():
    var laser_obj = laser_scene.instance()
    get_parent().add_child(laser_obj)
    
    var aim_direction = the_world.get_player().global_position - global_position
    laser_obj.set_initial_position(global_position)
    laser_obj.set_laser_velocity(aim_direction)

func set_tribot_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*TRIBOT_MAX_SPEED
