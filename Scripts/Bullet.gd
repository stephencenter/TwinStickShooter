extends Node2D

const BULLET_TRAVEL_SPEED : float = 20.0
const BULLET_LIFESPAN : float = 5.0
const BULLET_DAMAGE : int = 1

onready var player = get_parent().get_node("Player")
onready var lifespan_timer : Timer = $LifespanTimer
onready var hitbox : Area2D = $Hitbox

var current_velocity : Vector2

func _ready():
    lifespan_timer.start(BULLET_LIFESPAN)

func _process(_delta):
    global_position += current_velocity
    attempt_damage_enemies()
    
    if lifespan_timer.time_left == 0:
        self_destruct()

func set_bullet_velocity(direction : Vector2):
    direction = direction.normalized()
    current_velocity = direction*BULLET_TRAVEL_SPEED
    
func set_initial_position(initial_pos : Vector2):
    global_position = initial_pos

func attempt_damage_enemies():
    var areas = hitbox.get_overlapping_areas()
    if !areas.empty():
        var enemy = areas[0].get_parent()
        enemy.take_damage_from_player(BULLET_DAMAGE)
        self_destruct()

func self_destruct():
    get_parent().remove_child(self)