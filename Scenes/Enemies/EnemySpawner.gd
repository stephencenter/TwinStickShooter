extends Node

const BASE_TIME_BETWEEN_ENEMIES : float = 0.40
const MIN_TIME_BETWEEN_ENEMIES : float = 0.125
const TIME_FOR_MAX_DIFFICULTY : float = 120.0
const TIME_BETWEEN_DIFFICULTY_TICKS : float = 0.02

var time_between_enemies : float = BASE_TIME_BETWEEN_ENEMIES
var difficulty_ticks : int = 0

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = the_game.get_node("Interface")
onready var difficulty_timer : Timer = $DifficultyTimer

onready var jellybelly_timer : Timer = $JellybellySpawnTimer
onready var jellybelly_scene = load("res://Scenes/Enemies/Jellybelly.tscn")
const JELLYBELLY_TIME_MULTIPLIER : float = 1.5

onready var snakeray_scene = load("res://Scenes/Enemies/Snakeray.tscn")
onready var snakeray_timer : Timer = $SnakeraySpawnTimer
const SNAKERAY_TIME_MULTIPLIER : float = 20.0

onready var tribot_scene = load("res://Scenes/Enemies/Tribot.tscn")
onready var tribot_timer : Timer = $TribotSpawnTimer
const TRIBOT_TIME_MULTIPLIER : float = 50.0

func _process(_delta):        
    if the_game.is_player_alive():
        if jellybelly_timer.time_left == 0:
            spawn_jellybelly()
            jellybelly_timer.start(time_between_enemies*JELLYBELLY_TIME_MULTIPLIER)
        
        if snakeray_timer.time_left == 0:
            spawn_snakeray()
            snakeray_timer.start(time_between_enemies*SNAKERAY_TIME_MULTIPLIER)
            
        if tribot_timer.time_left == 0:
            spawn_tribot()
            tribot_timer.start(time_between_enemies*TRIBOT_TIME_MULTIPLIER)
            
        if difficulty_timer.time_left == 0:
            increase_difficulty()
            difficulty_timer.start(TIME_BETWEEN_DIFFICULTY_TICKS)

func start_spawner():
    difficulty_ticks = 0
    time_between_enemies = BASE_TIME_BETWEEN_ENEMIES
    jellybelly_timer.start(time_between_enemies*JELLYBELLY_TIME_MULTIPLIER)
    snakeray_timer.start(time_between_enemies*SNAKERAY_TIME_MULTIPLIER)
    tribot_timer.start(time_between_enemies*TRIBOT_TIME_MULTIPLIER)
    difficulty_timer.start(TIME_BETWEEN_DIFFICULTY_TICKS)
    
func increase_difficulty():
    if time_between_enemies > MIN_TIME_BETWEEN_ENEMIES:
        var abc = TIME_FOR_MAX_DIFFICULTY/TIME_BETWEEN_DIFFICULTY_TICKS
        var difference = BASE_TIME_BETWEEN_ENEMIES - MIN_TIME_BETWEEN_ENEMIES
        var quotient = abc/difference
        
        time_between_enemies = BASE_TIME_BETWEEN_ENEMIES - (difficulty_ticks/quotient)
        difficulty_ticks += 1
        
    else:
        time_between_enemies = MIN_TIME_BETWEEN_ENEMIES
        
# Enemy spawner
func get_jellybelly_spawnpoint(chosen_side : String) -> Vector2:
    # This chooses a random point along the specified edge of the screen.
    # This is used to determine where to spawn enemies
    # Margin ensures that enemies won't spawn in the corners
    var deadzone = 0.1
    var visible_pos = interface.get_visible_world_position()
    var world_size = get_viewport().get_visible_rect().size
    var min_x = visible_pos[0].x
    var min_y = visible_pos[0].y
    var max_x = visible_pos[1].x
    var max_y = visible_pos[1].y
    
    var chosen_x = rand_range(min_x + max_x*deadzone, max_x*(1 - deadzone))
    var chosen_y = rand_range(min_y + max_y*deadzone, max_y*(1 - deadzone))
    
    var buffer = 0.1
    var spawn_point : Vector2
    if chosen_side == "up":
        spawn_point = Vector2(chosen_x, min_y - world_size.y*buffer)  
    elif chosen_side == "down":
        spawn_point = Vector2(chosen_x, min_y + world_size.y*(1 + buffer))
    elif chosen_side == "left":
        spawn_point = Vector2(min_x - world_size.x*buffer, chosen_y)
    else:
        spawn_point = Vector2(min_x + world_size.x*(1 + buffer), chosen_y)
        
    return spawn_point

func get_jellybelly_spawnangle(chosen_side : String) -> Vector2:
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
    
func spawn_jellybelly():
    var sides : Array = ["up", "down", "left", "right"]
    var chosen_side = sides[randi() % sides.size()]
    var spawn_point = get_jellybelly_spawnpoint(chosen_side)
    var spawn_angle = get_jellybelly_spawnangle(chosen_side)
    var new_enemy = jellybelly_scene.instance()
    new_enemy.set_initial_position(spawn_point)
    new_enemy.set_jelly_velocity(spawn_angle)
    the_game.add_new_object(new_enemy)
    
# Enemy spawner
func get_snakeray_spawnpoint() -> Vector2:
    var visible_pos = interface.get_visible_world_position()
    var midpoint_x = (visible_pos[0].x + visible_pos[1].x)/2
    var midpoint_y = (visible_pos[0].y + visible_pos[1].y)/2
    var player_pos = the_game.get_player().global_position
    
    var chosen_side : bool = randi() % 2
    
    var spawnpoint : Vector2 = Vector2()
    # Player is in top-left, enemy spawns along bot-right
    if player_pos.x < midpoint_x and player_pos.y < midpoint_y:
        if chosen_side:
            spawnpoint.x = rand_range(midpoint_x, visible_pos[1].x)
            spawnpoint.y = visible_pos[1].y
        else:
            spawnpoint.x = visible_pos[1].x
            spawnpoint.y = rand_range(midpoint_y, visible_pos[1].y)
        
    # Player is in bot-left, enemy spawns along top-right
    elif player_pos.x < midpoint_x and player_pos.y >= midpoint_y:
        if chosen_side:
            spawnpoint.x = rand_range(midpoint_x, visible_pos[1].x)
            spawnpoint.y = visible_pos[0].y
        else:
            spawnpoint.x = visible_pos[1].x
            spawnpoint.y = rand_range(visible_pos[0].y, midpoint_y)
    
    # Player is in top-right, enemy spawns along bot-right
    elif player_pos.x >= midpoint_x and player_pos.y < midpoint_y:
        if chosen_side:
            spawnpoint.x = rand_range(visible_pos[0].x, midpoint_x)
            spawnpoint.y = visible_pos[1].y
        else:
            spawnpoint.x = visible_pos[0].x
            spawnpoint.y = rand_range(midpoint_y, visible_pos[1].y)
    
    # Player is in bot-right, enemy spawns along top-left
    else:
        if chosen_side:
            spawnpoint.x = rand_range(visible_pos[0].x, midpoint_x)
            spawnpoint.y = visible_pos[0].y
        else:
            spawnpoint.x = visible_pos[0].x
            spawnpoint.y = rand_range(visible_pos[0].y, midpoint_y)
        
    return spawnpoint

func get_snakeray_spawnangle(var spawnpoint : Vector2) -> Vector2:
    var player_pos = the_game.get_player().global_position
    return player_pos - spawnpoint

func spawn_snakeray():
    var spawn_point = get_snakeray_spawnpoint()
    var spawn_angle = get_snakeray_spawnangle(spawn_point)
    
    var new_enemy = snakeray_scene.instance()
    new_enemy.set_initial_position(spawn_point)
    new_enemy.set_snake_velocity(spawn_angle)
    the_game.add_new_object(new_enemy)

func get_tribot_spawnside():
    var options = [
        ["topleft", "down"], ["topleft", "right"], 
        ["botleft", "up"], ["botleft", "right"],
        ["topright", "down"], ["topright", "left"],
        ["botright", "up"], ["botright", "left"]
    ]
    
    return options[randi() % options.size()]
    
func get_tribot_spawnpoint(var spawn_side : Array) -> Vector2:
    var world_size = get_viewport().get_visible_rect().size
    var corner = spawn_side[0]
    var direction = spawn_side[1]
    var margin = 0.05
    
    var spawnpoint : Vector2 = Vector2()
    
    if corner == "topleft":
        if direction == "down":
            spawnpoint.x = world_size.x*margin
            spawnpoint.y = -world_size.y*margin
        
        elif direction == "right":
            spawnpoint.x = -world_size.x*margin
            spawnpoint.y = world_size.y*margin
            
    elif corner == "botleft":
        if direction == "up":
            spawnpoint.x = world_size.x*margin
            spawnpoint.y = world_size.y*(1 + margin)
            
        elif direction == "right":
            spawnpoint.x = -world_size.x*margin
            spawnpoint.y = world_size.y*(1 - margin)
    
    elif corner == "topright":
        if direction == "down":
            spawnpoint.x = world_size.x*(1 - margin)
            spawnpoint.y = -world_size.y*margin
            
        elif direction == "left":
            spawnpoint.x = world_size.x*(1 + margin)
            spawnpoint.y = world_size.y*margin
            
    else: #botright
        if direction == "up":
            spawnpoint.x = world_size.x*(1 - margin)
            spawnpoint.y = world_size.y*(1 + margin)
            
        if direction == "left":
            spawnpoint.x = world_size.x*(1 + margin)
            spawnpoint.y = world_size.y*(1 - margin)
            
    return spawnpoint
            
func get_tribot_spawnangle(var direction) -> Vector2:
    if direction == "up":
        return Vector2(0, -1)
        
    elif direction == "down":
        return Vector2(0, 1)
        
    elif direction == "left":
        return Vector2(-1, 0)
        
    return Vector2(1, 0)
        
    
func spawn_tribot():
    var spawn_side = get_tribot_spawnside()
    var spawn_point = get_tribot_spawnpoint(spawn_side)
    var spawn_angle = get_tribot_spawnangle(spawn_side[1])
    
    var new_enemy = tribot_scene.instance()
    new_enemy.set_initial_position(spawn_point)
    new_enemy.set_tribot_velocity(spawn_angle)
    the_game.add_new_object(new_enemy)
