extends Node2D

# Constants (points)
const TIME_BETWEEN_POINTS : float = 1/45.0
const POINTS_PER_TICK : int = 10
const POINTS_PER_ENEMY : int = 1000

# Constants (difficulty)
const BASE_TIME_BETWEEN_SPAWNS : float = 0.75
const MIN_TIME_BETWEEN_SPAWNS : float = 0.15
const TIME_FOR_MAX_DIFFICULTY : float = 120.0

# Variables
var current_score : int = 0
var start_time : int = 0
var current_time : int = 0
var time_between_spawns : float = BASE_TIME_BETWEEN_SPAWNS
var challenge_count : int = 0

# Nodes
onready var spawn_timer : Timer = $EnemySpawnTimer
onready var points_timer : Timer = $AlivePointsTimer
onready var enemy_container = $EnemyContainer
onready var enemy_to_spawn = load("res://Scenes/Enemy.tscn")
onready var player_scene = load("res://Scenes/Player.tscn")

# Update
func _ready():
    start_new_game()

func _process(delta):
    if has_node("Player"):
        if spawn_timer.time_left == 0:
            spawn_enemy()
            spawn_timer.start(time_between_spawns)
        
        current_time = OS.get_unix_time()
        reward_alive_points()
        increase_difficulty(delta)
            
    else:
        if Input.is_action_just_pressed("new_game"):
            start_new_game()
            
    update_hud()

func update_hud():
    $CanvasLayer/CurrentScore.set_text("SCORE: %s" % current_score)
    
    var elapsed_time = current_time - start_time
    var minutes = elapsed_time / 60
    var seconds = elapsed_time % 60
    var string_time : String = "%02d:%02d" % [minutes, seconds]
    $CanvasLayer/ElapsedTime.set_text("TIME: %s" % string_time)
    
func start_new_game():
    # Spawn Player
    var spawn_point = get_viewport().size/2
    var player_obj = player_scene.instance()
    player_obj.global_position = spawn_point
    add_child(player_obj)
    
    # Clear enemies
    for object in enemy_container.get_children():
        enemy_container.remove_child(object)
    challenge_count = 0
    
    # Reset score
    current_score = 0
    points_timer.start(TIME_BETWEEN_POINTS)
    
    # Get the time the game started
    start_time = OS.get_unix_time()
    
    # Start spawning enemies
    spawn_timer.start(time_between_spawns)
    
# Enemy spawner
func get_random_spawnpoint(chosen_side : String) -> Vector2:
    # This chooses a random point along the specified edge of the screen.
    # This is used to determine where to spawn enemies
    var screen_size = get_viewport().size
    var margin = 0.1
    var chosen_x = rand_range(screen_size.x*margin, screen_size.x*(1 - margin))
    var chosen_y = rand_range(screen_size.y*margin, screen_size.y*(1 - margin))
    
    var spawn_point : Vector2
    if chosen_side == "up":
        spawn_point = Vector2(chosen_x, 0)  
    elif chosen_side == "down":
        spawn_point = Vector2(chosen_x, screen_size.y)
    elif chosen_side == "left":
        spawn_point = Vector2(0, chosen_y)
    else:
        spawn_point = Vector2(screen_size.x, chosen_y)
        
    return spawn_point

func get_random_spawnangle(chosen_side : String) -> Vector2:
    # This gets a random angle between -45 and 45 degrees, perpendicular 
    # to the specified screen edge. This is used to give enemies a random
    # direciton to travel in when spawned
    var spawn_angle : Vector2 = Vector2()
    if chosen_side == "up":
        spawn_angle.x = rand_range(-0.5, 0.5)
        spawn_angle.y = rand_range(0, 1)
        
    elif chosen_side == "down":
        spawn_angle.x = rand_range(-0.5, 0.5)
        spawn_angle.y = rand_range(-1, 0)
        
    elif chosen_side == "left":
        spawn_angle.x = rand_range(0, 1)
        spawn_angle.y = rand_range(-0.5, 0.5)
        
    else:
        spawn_angle.x = rand_range(-1, 0)
        spawn_angle.y = rand_range(-0.5, 0.5)
        
    return spawn_angle
    
func spawn_enemy():
    var sides : Array = ["up", "down", "left", "right"]
    var chosen_side = sides[randi() % sides.size()]
    var spawn_point = get_random_spawnpoint(chosen_side)
    var spawn_angle = get_random_spawnangle(chosen_side)
    
    var new_enemy = enemy_to_spawn.instance()
    enemy_container.add_child(new_enemy)
    
    new_enemy.set_initial_position(spawn_point)
    new_enemy.set_enemy_velocity(spawn_angle)

# Points
func reward_alive_points():
    if points_timer.time_left == 0:
        current_score += POINTS_PER_TICK
        points_timer.start(TIME_BETWEEN_POINTS)
        
func reward_enemy_points():
    current_score += POINTS_PER_ENEMY
    
func increase_difficulty(delta):
    if time_between_spawns > MIN_TIME_BETWEEN_SPAWNS:
        # I find that the linear algorithm starts out too slow, and the
        # log algorithm starts out too fast. So we average them.
        var linear = calculate_difficulty_linear(delta)
        var logarithmic = calculate_difficulty_log(delta)
        time_between_spawns = (linear + logarithmic)/2
        
        challenge_count += 1
        
    else:
        time_between_spawns = MIN_TIME_BETWEEN_SPAWNS
        
        
func calculate_difficulty_linear(delta):    
    var num_ticks = TIME_FOR_MAX_DIFFICULTY/max(delta, 0.000001) - 1
    var difference = BASE_TIME_BETWEEN_SPAWNS - MIN_TIME_BETWEEN_SPAWNS
    var quotient = num_ticks/difference
    
    return BASE_TIME_BETWEEN_SPAWNS - (challenge_count/quotient)
    
func calculate_difficulty_log(delta):
    var num_ticks = TIME_FOR_MAX_DIFFICULTY/max(delta, 0.000001)
    var degree = BASE_TIME_BETWEEN_SPAWNS - MIN_TIME_BETWEEN_SPAWNS
    var log_base = pow(num_ticks, 1.0/degree)
    return BASE_TIME_BETWEEN_SPAWNS - log(challenge_count + 1)/log(log_base)
