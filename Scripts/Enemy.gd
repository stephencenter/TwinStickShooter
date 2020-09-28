extends Node2D

const ENEMY_MAX_HEALTH : int = 5
const ENEMY_MAX_SPEED : float = 5.0
const ENEMY_MIN_SPEED : float = 3.0
const ENEMY_LIFESPAN : float = 10.0

var current_health : int = ENEMY_MAX_HEALTH
var current_velocity : Vector2

onready var hitbox : Area2D = $Hitbox
onready var lifespan_timer : Timer = $LifespanTimer
onready var the_world : Node2D = get_parent().get_parent()

func _ready():
    lifespan_timer.start(ENEMY_LIFESPAN)
    
func _process(_delta):
    global_position += current_velocity
    attempt_damage_player()
    
    if lifespan_timer.time_left == 0:
        self_destruct()

func take_damage_from_player(damage_amount : int):
    current_health -= damage_amount
    if current_health <= 0:
        the_world.reward_enemy_points()
        self_destruct()

func attempt_damage_player():
    for area in hitbox.get_overlapping_areas():
        if area.get_parent() == the_world.get_node("Player"):
            var player = area.get_parent()
            player.self_destruct()

func set_enemy_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*rand_range(ENEMY_MIN_SPEED, ENEMY_MAX_SPEED)
    if current_velocity.x < 0:
        get_node("Sprite").set_flip_h(true)
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos
    
func self_destruct():
    get_parent().remove_child(self)

