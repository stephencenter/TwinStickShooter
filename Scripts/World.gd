extends Node2D

# Constants (points)
const TIME_BETWEEN_POINTS : float = 0.02222222222222
const POINTS_PER_TICK : int = 10
const POINTS_PER_ENEMY : int = 1000

# Constants (difficulty)

const BASE_TIME_BETWEEN_ENEMIES : float = 0.60
const MIN_TIME_BETWEEN_ENEMIES : float = 0.15
const TIME_FOR_MAX_DIFFICULTY : float = 120.0
const TIME_BETWEEN_DIFFICULTY_TICKS : float = 0.016666666666667
const TICKS_FOR_MAX_DIFFICULTY : int = int(TIME_FOR_MAX_DIFFICULTY/TIME_BETWEEN_DIFFICULTY_TICKS)

# Constants (powerups)
const TIME_BETWEEN_POWERUPS : float = 20.0

# Variables
var current_score : int = 0
var start_time : int = 0
var current_time : int = 0
var time_between_enemies : float = BASE_TIME_BETWEEN_ENEMIES
var difficulty_ticks : int = 0
var previous_powerup : int = -1

# Nodes
onready var enemy_spawn_timer : Timer = $EnemySpawnTimer
onready var points_timer : Timer = $AlivePointsTimer
onready var difficulty_timer : Timer = $DifficultyTimer
onready var powerup_spawn_timer : Timer = $PowerupSpawnTimer
onready var object_container = $ObjectContainer

# Scenes
onready var enemy_to_spawn = load("res://Scenes/Enemy.tscn")
onready var player_scene = load("res://Scenes/Player.tscn")
onready var powerup_to_spawn = load("res://Scenes/Powerup.tscn")

# Update
func _ready():
    start_new_game()

func _process(_delta):
    if is_player_alive():
        if enemy_spawn_timer.time_left == 0:
            spawn_enemy()
            enemy_spawn_timer.start(time_between_enemies)
            
        if difficulty_timer.time_left == 0:
            increase_difficulty()
            difficulty_timer.start(TIME_BETWEEN_DIFFICULTY_TICKS)
            
        if powerup_spawn_timer.time_left == 0:
            spawn_powerup()
            powerup_spawn_timer.start(TIME_BETWEEN_POWERUPS)
        
        current_time = OS.get_unix_time()
        reward_alive_points()
        
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
    
    var fps = Engine.get_frames_per_second()
    $CanvasLayer/Framerate.set_text("%s FPS" % fps)
    
func start_new_game():    
    # Clear objects
    for object in object_container.get_children():
        object_container.remove_child(object)
    
    # Spawn Player
    var spawn_point_x = ProjectSettings.get_setting("display/window/size/width")/2
    var spawn_point_y = ProjectSettings.get_setting("display/window/size/height")/2
    var player_obj = player_scene.instance()
    player_obj.global_position = Vector2(spawn_point_x, spawn_point_y)
    object_container.add_child(player_obj)
    
    # Reset score
    current_score = 0
    points_timer.start(TIME_BETWEEN_POINTS)
    
    # Get the time the game started
    start_time = OS.get_unix_time()
    
    # Start spawning enemies, powerups, and increasing the difficulty
    difficulty_ticks = 0
    enemy_spawn_timer.start(time_between_enemies)
    difficulty_timer.start(TIME_BETWEEN_DIFFICULTY_TICKS)
    powerup_spawn_timer.start(TIME_BETWEEN_POWERUPS)

func is_player_alive():
    return object_container.has_node("Player")

func get_player():
    if is_player_alive():
        return object_container.get_node("Player")
    return null
    
# Enemy spawner
func get_enemy_spawnpoint(chosen_side : String) -> Vector2:
    # This chooses a random point along the specified edge of the screen.
    # This is used to determine where to spawn enemies
    # Margin ensures that enemies won't spawn in the corners
    var deadzone = 0.1
    var screen_size_x = ProjectSettings.get_setting("display/window/size/width")
    var screen_size_y = ProjectSettings.get_setting("display/window/size/height")
    var chosen_x = rand_range(screen_size_x*deadzone, screen_size_x*(1 - deadzone))
    var chosen_y = rand_range(screen_size_y*deadzone, screen_size_y*(1 - deadzone))
    
    var buffer = 0.1
    var spawn_point : Vector2
    if chosen_side == "up":
        spawn_point = Vector2(chosen_x, -screen_size_y*buffer)  
    elif chosen_side == "down":
        spawn_point = Vector2(chosen_x, screen_size_y*(1 + buffer))
    elif chosen_side == "left":
        spawn_point = Vector2(-screen_size_x*buffer, chosen_y)
    else:
        spawn_point = Vector2(screen_size_x*(1 + buffer), chosen_y)
        
    return spawn_point

func get_enemy_spawnangle(chosen_side : String) -> Vector2:
    # This gets a random angle between -45 and 45 degrees, perpendicular 
    # to the specified screen edge. This is used to give enemies a random
    # direction to travel in when spawned
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
    var spawn_point = get_enemy_spawnpoint(chosen_side)
    var spawn_angle = get_enemy_spawnangle(chosen_side)
    
    var new_enemy = enemy_to_spawn.instance()
    object_container.add_child(new_enemy)
    
    new_enemy.set_initial_position(spawn_point)
    new_enemy.set_enemy_velocity(spawn_angle)

# Points
func reward_alive_points():
    if points_timer.time_left == 0:
        current_score += POINTS_PER_TICK
        points_timer.start(TIME_BETWEEN_POINTS)
        
func reward_enemy_points():
    current_score += POINTS_PER_ENEMY
    
func increase_difficulty():
    if time_between_enemies > MIN_TIME_BETWEEN_ENEMIES:
        # I find that the linear algorithm starts out too slow, and the
        # log algorithm starts out too fast. So we average them.
        var linear = calculate_difficulty_linear()
        var logarithmic = calculate_difficulty_log()
        time_between_enemies = (linear + logarithmic)/2
        
        difficulty_ticks += 1
        
    else:
        time_between_enemies = MIN_TIME_BETWEEN_ENEMIES
        
func calculate_difficulty_linear():
    var abc = TICKS_FOR_MAX_DIFFICULTY
    var difference = BASE_TIME_BETWEEN_ENEMIES - MIN_TIME_BETWEEN_ENEMIES
    var quotient = abc/difference
    
    return BASE_TIME_BETWEEN_ENEMIES - (difficulty_ticks/quotient)
    
func calculate_difficulty_log():
    var abc = TICKS_FOR_MAX_DIFFICULTY
    var degree = BASE_TIME_BETWEEN_ENEMIES - MIN_TIME_BETWEEN_ENEMIES
    var log_base = pow(abc, 1.0/degree)
    return BASE_TIME_BETWEEN_ENEMIES - log(difficulty_ticks + 1)/log(log_base)

# Powerup spawner
func get_powerup_spawnpoint() -> Vector2:
    var margin = 0.05
    var screen_size_x = ProjectSettings.get_setting("display/window/size/width")
    var screen_size_y = ProjectSettings.get_setting("display/window/size/height")
    var chosen_x = rand_range(screen_size_x*margin, screen_size_x*(1 - margin))
    var chosen_y = rand_range(screen_size_y*margin, screen_size_y*(1 - margin))
    
    return Vector2(chosen_x, chosen_y)

func spawn_powerup():
    var spawn_point = get_powerup_spawnpoint()
    var new_powerup = powerup_to_spawn.instance()
    object_container.add_child(new_powerup)
    
    new_powerup.set_powerup_position(spawn_point)
    previous_powerup = new_powerup.choose_powerup_type(previous_powerup)
    new_powerup.set_powerup_type(previous_powerup)
