extends Node

onready var the_game = get_tree().get_root().get_node("Game")
onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]
onready var points_timer = timer_class.new(ACTIVE_STATES, the_game)

const TIME_BETWEEN_POINTS : float = 0.02
const POINTS_PER_TICK : int = 10
var current_score : int = 0
      
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
        
    if the_game.get_player().is_alive():
        reward_alive_points()

func start_scoring():
    current_score = 0
    points_timer.start(TIME_BETWEEN_POINTS)

func reward_alive_points():
    if points_timer.is_stopped():
        current_score += POINTS_PER_TICK
        points_timer.start(TIME_BETWEEN_POINTS)
        
func reward_enemy_points(var enemy):
    current_score += enemy.ENEMY_POINT_REWARD
