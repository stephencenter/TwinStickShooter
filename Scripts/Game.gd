extends Node2D

# Constants (points)
const TIME_BETWEEN_POINTS : float = 0.02
const POINTS_PER_TICK : int = 10

# Constants (powerups)
const TIME_BETWEEN_POWERUPS : float = 16.0

# Variables
var current_score : int = 0
var start_time : int = 0
var current_time : int = 0
var previous_powerup : int = -1

# Nodes
onready var points_timer : Timer = $AlivePointsTimer
onready var powerup_spawn_timer : Timer = $PowerupSpawnTimer
onready var object_container = $ObjectContainer
onready var interface : CanvasLayer = $Interface

# Scenes
onready var player_scene = load("res://Scenes/Player.tscn")
onready var powerup_to_spawn = load("res://Scenes/Powerup.tscn")

# Update
func _ready():
    start_new_game()

func _process(_delta):
    if get_player().is_alive():            
        if powerup_spawn_timer.time_left == 0:
            spawn_powerup()
            powerup_spawn_timer.start(TIME_BETWEEN_POWERUPS)
            
        reward_alive_points()
        
    else:
        if Input.is_action_just_pressed("new_game"):
            start_new_game()

func get_player():
    return object_container.get_node("Player")

func get_player_position():        
    return get_player().global_position
    
func get_player_screen_position():
    return get_player().get_global_transform_with_canvas().origin

func add_new_object(var the_object):
    object_container.add_child(the_object)
    
func start_new_game():
    # Generate new RNG seed
    randomize()
     
    # Clear objects
    for object in object_container.get_children():
        object_container.remove_child(object)
    
    # Spawn Player
    var player_obj = player_scene.instance()
    player_obj.global_position = get_viewport().get_visible_rect().size/2
    object_container.add_child(player_obj)
    
    # Reset score
    current_score = 0
    points_timer.start(TIME_BETWEEN_POINTS)
    
    # Get the time the game started
    start_time = OS.get_unix_time()
    
    # Start spawning enemies, powerups, and increasing the difficulty
    $EnemySpawner.start_spawner()
    powerup_spawn_timer.start(TIME_BETWEEN_POWERUPS)
    
# Points
func reward_alive_points():
    if points_timer.time_left == 0:
        current_score += POINTS_PER_TICK
        points_timer.start(TIME_BETWEEN_POINTS)
        
func reward_enemy_points(var enemy):
    current_score += enemy.ENEMY_POINT_REWARD

# Powerup spawner
func get_powerup_spawnpoint() -> Vector2:
    var deadzone = 0.1
    var visible_pos = interface.get_visible_world_position()
    var min_x = visible_pos[0].x
    var min_y = visible_pos[0].y
    var max_x = visible_pos[1].x
    var max_y = visible_pos[1].y
    
    var chosen_x = rand_range(min_x + max_x*deadzone, max_x*(1 - deadzone))
    var chosen_y = rand_range(min_y + max_y*deadzone, max_y*(1 - deadzone))
    
    return Vector2(chosen_x, chosen_y)

func spawn_powerup():
    var spawn_point = get_powerup_spawnpoint()
    var new_powerup = powerup_to_spawn.instance()
    object_container.add_child(new_powerup)
    
    new_powerup.set_powerup_position(spawn_point)
    previous_powerup = new_powerup.choose_powerup_type(previous_powerup)
    new_powerup.set_powerup_type(previous_powerup)
