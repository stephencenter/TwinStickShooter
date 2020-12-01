extends "res://Scenes/Ingame/Projectile.gd"

func _ready():
    PROJECTILE_TRAVEL_SPEED = 800.0
    PROJECTILE_DAMAGE = 1
    PIERCES_ENTITIES = false
    
func _process(_delta):
    update_projectile_target()

func update_projectile_target():
    if not PROJECTILE_OWNER == the_game.get_player() or not the_game.get_player().has_powerup(3):
        PROJECTILE_TARGET = null
        return
    
    var areas = $HomingRadius.get_overlapping_areas()
    var closest_enemy : Node2D
    var closest_distance : float = -1
    
    for area in areas:                
        var distance = global_position.distance_to(area.global_position)
        if distance < closest_distance or closest_distance < 0:
            closest_distance = distance
            closest_enemy = area.get_parent()
            
    set_projectile_target(closest_enemy)
