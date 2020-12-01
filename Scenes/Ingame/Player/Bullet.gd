extends "res://Scenes/Ingame/Projectile.gd"

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var lifespan_timer = timer_class.new([the_game.GameState.INGAME], the_game)

func _ready():
    lifespan_timer.start(PROJECTILE_LIFESPAN)
    PROJECTILE_TRAVEL_SPEED = 800.0
    PROJECTILE_DAMAGE = 1
    PIERCES_ENTITIES = false
    
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
    
    update_projectile_target()
    manage_lifespan_timer()

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
        
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(PROJECTILE_LIFESPAN)
    
    if lifespan_timer.is_stopped():
        queue_free()
