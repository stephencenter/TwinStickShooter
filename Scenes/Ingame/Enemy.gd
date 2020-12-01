extends Node2D

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var score_manager : Node = get_tree().get_root().get_node("Game/ScoreManager")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var lifespan_timer = timer_class.new(ACTIVE_STATES, the_game)

const ENEMY_LIFESPAN : float = 5.0
var ENEMY_MAX_HEALTH : int
var ENEMY_ATTACK_DAMAGE : int
var ENEMY_POINT_REWARD : int 
var ENEMY_MOVE_SPEED : float
var current_health : int
var current_velocity : Vector2

func _ready():
    lifespan_timer.start(ENEMY_LIFESPAN)
        
func _process(delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
        
    process_movement(delta)
    attempt_damage_player()
    manage_lifespan_timer()

func process_movement(var _delta):
    pass
    
func take_damage(damage_amount : int):        
    current_health -= damage_amount
    if current_health <= 0:
        score_manager.reward_enemy_points(self)
        queue_free()
    
func attempt_damage_player():        
    for area in $Hitbox.get_overlapping_areas():
        var entity = area.get_parent()
        if entity == the_game.get_player():
            entity.take_damage(ENEMY_ATTACK_DAMAGE)
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
    
func manage_lifespan_timer():
    if the_game.is_object_on_screen(self):
        lifespan_timer.start(ENEMY_LIFESPAN)
    
    if lifespan_timer.is_stopped():
        queue_free()
