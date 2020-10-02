extends Node2D

const ENEMY_MAX_HEALTH : int = 3
const ENEMY_MAX_SPEED : float = 167.0
const ENEMY_MIN_SPEED : float = 100.0
const ENEMY_LIFESPAN : float = 5.0
const ENEMY_ATTACK_DAMAGE : int = 1

onready var hitbox : Area2D = $Hitbox
onready var lifespan_timer : Timer = $LifespanTimer
onready var the_world : Node2D = get_tree().get_root().get_node("World")
onready var interface : CanvasLayer = the_world.get_node("Interface")

var current_health : int = ENEMY_MAX_HEALTH
var current_velocity : Vector2

func _ready():
    lifespan_timer.start(ENEMY_LIFESPAN)
    
func _process(delta):
    if !is_inside_tree():
        return
        
    keep_alive_if_inbounds()
    global_position += current_velocity*delta
    attempt_damage_player()

    if lifespan_timer.time_left == 0:
        self_destruct()
    
func take_damage_from_player(damage_amount : int):
    current_health -= damage_amount
    if current_health <= 0:
        the_world.reward_enemy_points()
        self_destruct()

func attempt_damage_player():
    if !the_world.is_player_alive():
        return
        
    for area in hitbox.get_overlapping_areas():
        var entity = area.get_parent()
        if entity == the_world.get_player():
            entity.take_damage_from_enemy(ENEMY_ATTACK_DAMAGE)

func set_enemy_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*rand_range(ENEMY_MIN_SPEED, ENEMY_MAX_SPEED)
    if current_velocity.x < 0:
        get_node("Sprite").set_flip_h(true)
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
    
func keep_alive_if_inbounds():
    var visible_pos =  interface.get_visible_world_position()
    var top_left = visible_pos[0]
    var bot_right = visible_pos[1]
    
    if global_position.x > top_left.x and global_position.x < bot_right.x:
        if global_position.y > top_left.y and global_position.y < bot_right.y:
            lifespan_timer.start(ENEMY_LIFESPAN)
            
func self_destruct():
    if is_inside_tree():
        get_parent().remove_child(self)
