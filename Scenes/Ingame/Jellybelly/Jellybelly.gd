extends "res://Scenes/Ingame/Enemy.gd"

const JELLY_MIN_SPEED : float = 100.0
const JELLY_MAX_SPEED : float = 167.0

func _ready():
    ENEMY_MAX_HEALTH = 3
    ENEMY_ATTACK_DAMAGE = 1
    ENEMY_POINT_REWARD = 1000
    current_health = ENEMY_MAX_HEALTH
    
func process_movement(var delta : float):
    global_position += current_velocity*delta

func set_jelly_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*rand_range(JELLY_MIN_SPEED, JELLY_MAX_SPEED)
