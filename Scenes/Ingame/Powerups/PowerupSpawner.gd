extends Node

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var powerup_to_spawn = load("res://Scenes/Ingame/Powerups/Powerup.tscn")
onready var powerup_spawn_timer = timer_class.new(ACTIVE_STATES, the_game)

const TIME_BETWEEN_POWERUPS : float = 16.0
var previous_powerup : int = -1
      
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
        
    if the_game.get_player().is_alive():            
        if powerup_spawn_timer.is_stopped():
            spawn_powerup()
            powerup_spawn_timer.start(TIME_BETWEEN_POWERUPS)

func start_spawner():
    previous_powerup = -1
    powerup_spawn_timer.start(TIME_BETWEEN_POWERUPS)
    
func get_powerup_spawnpoint() -> Vector2:
    var deadzone = 0.1
    var world_rect = the_game.get_visible_world_rect()
    var min_x = world_rect[0].x
    var min_y = world_rect[0].y
    var max_x = world_rect[1].x
    var max_y = world_rect[1].y
    
    var chosen_x = rand_range(min_x + max_x*deadzone, max_x*(1 - deadzone))
    var chosen_y = rand_range(min_y + max_y*deadzone, max_y*(1 - deadzone))
    
    return Vector2(chosen_x, chosen_y)

func spawn_powerup():
    var spawn_point = get_powerup_spawnpoint()
    var new_powerup = powerup_to_spawn.instance()
    the_game.add_new_object(new_powerup)
    
    new_powerup.set_powerup_position(spawn_point)
    previous_powerup = new_powerup.choose_powerup_type(previous_powerup)
    new_powerup.set_powerup_type(previous_powerup)
