extends "res://Scenes/Enemies/Enemy.gd"

const SNAKE_MOVE_SPEED : float = 400.0

func _ready():
    ENEMY_MAX_HEALTH = 10
    ENEMY_ATTACK_DAMAGE = 1
    ENEMY_POINT_REWARD = 10000
    current_health = ENEMY_MAX_HEALTH
    
func process_movement(var delta : float):
    global_position += current_velocity*delta


func set_snake_velocity(direction : Vector2):
    direction = direction.normalized()
    rotation = direction.angle()
    current_velocity = direction*SNAKE_MOVE_SPEED
    if current_velocity.x < 0:
        get_node("Sprite").set_flip_v(true)
        
