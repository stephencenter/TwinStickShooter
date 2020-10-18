extends Node2D

onready var interface : CanvasLayer = $Interface
onready var object_container : Node = $ObjectContainer
onready var player_scene = load("res://Scenes/Player/Player.tscn")

var the_player : Node2D = null
var start_time : int = 0

# Update
func _ready():
    start_new_game()

func _process(_delta):
    if !get_player().is_alive() and Input.is_action_just_pressed("new_game"):
        start_new_game()
        
func start_new_game():
    # Generate new RNG seed
    randomize()
     
    # Clear objects
    for object in object_container.get_children():
        object_container.remove_child(object)
    
    # Spawn Player
    the_player = player_scene.instance()
    the_player.global_position = get_viewport().get_visible_rect().size/2
    add_new_object(the_player)
    
    # Get the time the game started
    start_time = OS.get_unix_time()
    
    # Start spawning enemies, powerups, and tracking score
    $EnemySpawner.start_spawner()
    $PowerupSpawner.start_spawner()
    $ScoreManager.start_scoring()

func get_player():
    return the_player

func get_player_global_position():
    # Returns the position of the player relative to the world origin
    return get_player().global_position
    
func get_player_screen_position():
    # Returns the position of the player relative to the top-left corner of the screen
    return get_player().get_global_transform_with_canvas().origin

func get_visible_world_rect() -> Array:
    # Returns the global_position of the top-left and bottom-right
    # corners of the visible world space as an array.
    # index 0 is top-left, index 1 is bot-right
    var screen_size = get_viewport().get_visible_rect().size
    var player_pos = get_player_global_position()
    var screen_pos = get_player_screen_position()
    var top_left = player_pos - screen_pos
    var bot_right = top_left + screen_size
    
    return [top_left, bot_right]
    
func is_object_on_screen(object) -> bool:
    var world_rect =  get_visible_world_rect()
    var top_left = world_rect[0]
    var bot_right = world_rect[1]
    
    if object.global_position.x > top_left.x:
        if object.global_position.x < bot_right.x:
            if object.global_position.y > top_left.y:
                if object.global_position.y < bot_right.y:
                    return true
    return false
    
func add_new_object(var the_object):
    object_container.add_child(the_object)
    
