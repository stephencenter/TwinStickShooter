extends "res://Scenes/Ingame/Enemy.gd"

func _ready():
    self.ENEMY_MAX_HEALTH = 10
    self.ENEMY_ATTACK_DAMAGE = 1
    self.ENEMY_POINT_REWARD = 10000
    self.ENEMY_MOVE_SPEED = 500.0
    self.current_health = ENEMY_MAX_HEALTH
    
func process_movement(var delta : float):
    global_position += current_velocity*delta

func set_snake_velocity(direction : Vector2):
    direction = direction.normalized()
    rotation = direction.angle()
    current_velocity = direction*ENEMY_MOVE_SPEED
    if current_velocity.x < 0:
        get_node("Sprite").set_flip_v(true)
        
