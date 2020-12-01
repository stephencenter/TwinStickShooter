extends "res://Scenes/Ingame/Enemy.gd"

func _ready():
    self.ENEMY_MAX_HEALTH = 3
    self.ENEMY_ATTACK_DAMAGE = 1
    self.ENEMY_POINT_REWARD = 1000
    self.ENEMY_MOVE_SPEED = rand_range(100.0, 167.0)
    self.current_health = ENEMY_MAX_HEALTH
    
func process_movement(var delta):
    global_position += current_velocity*delta

func set_jelly_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*ENEMY_MOVE_SPEED
