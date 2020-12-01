extends "res://Scenes/Ingame/Projectile.gd"

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var lifespan_timer = timer_class.new([the_game.GameState.INGAME], the_game)

func _ready():
    lifespan_timer.start(PROJECTILE_LIFESPAN)
    PROJECTILE_TRAVEL_SPEED = 400.0
    PROJECTILE_DAMAGE = 1
    PIERCES_ENTITIES = false
    
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return
        
    manage_lifespan_timer()
    
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(PROJECTILE_LIFESPAN)
    
    if lifespan_timer.is_stopped():
        queue_free()
