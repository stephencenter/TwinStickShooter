extends Node2D

onready var the_game = get_tree().get_root().get_node("Game")
onready var interface : CanvasLayer = get_tree().get_root().get_node("Game/Interface")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

const PLAYER_MAX_HEALTH : int = 3
const PLAYER_MAX_SPEED : float = 250.0
const PLAYER_ACCELERATION : float = 0.2
const PLAYER_DECELERATION : float = 0.1
const PLAYER_TURN_SPEED : float = 20.0
const PRIMARY_FIRE_CD : float = 0.1
const POWERUP_DURATION : float = 10.0
const JOY_LEFT_DEADZONE : float = 0.05
const JOY_RIGHT_DEADZONE : float = 0.5
const JOY_CROSSHAIR_DISTANCE : float = 120.0
const PLAYER_INVINCE_TIME : float = 1.5
const PLAYER_FLICKER_TIME : float = 0.1
const PLAYER_DASH_SPEED : float = 1000.0
const PLAYER_DASH_DURATION : float = 0.2
const PLAYER_DASH_COOLDOWN : float = 0.3
const PLAYER_PARRY_DURATION : float = 0.3
const PLAYER_PARRY_COOLDOWN : float = 0.6

onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var bullet_scene = load("res://Scenes/Ingame/Player/Bullet.tscn")

onready var collection_radius : Area2D = $CollectionRadius
onready var joy_crosshair : Sprite = $Crosshair

onready var pfire_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var iframes_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var flicker_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var dash_active_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var dash_cd_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var parry_active_timer = timer_class.new(ACTIVE_STATES, the_game)
onready var parry_cd_timer = timer_class.new(ACTIVE_STATES, the_game)

onready var powerup_timers = {
    0: timer_class.new(ACTIVE_STATES, the_game),
    1: timer_class.new(ACTIVE_STATES, the_game),
    2: timer_class.new(ACTIVE_STATES, the_game),
    3: timer_class.new(ACTIVE_STATES, the_game)
}

var current_velocity : Vector2
var movement_vector : Vector2
var dash_direction : Vector2
var current_aim : Vector2
var aim_vector : Vector2
var aimed_mouse : bool = false
var current_health : int = PLAYER_MAX_HEALTH

# Updates        
func _process(delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
   
    if not is_alive():
        visible = false
        return
        
    process_input(delta)
    process_movement(delta)
    process_rotation(delta)
    attempt_collect_powerups()
    update_crosshair_position()
    update_barrier_sprite()
    update_parry_sprite()
    invincibility_sprite_flicker()

    if pfire_timer.is_stopped():
        action_primary_fire()	

func _input(event):
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
            get_viewport().warp_mouse(joy_crosshair.global_position)
            
        interface.enable_mouse_cursor()
        aimed_mouse = true
    
func process_input(_delta):
    movement_vector = get_movement_vector()
    aim_vector = get_aim_joystick()
    
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
        aim_vector = get_global_mouse_position() - global_position
        
    if Input.is_action_just_pressed("dash"):
        action_dash()
        
    if Input.is_action_just_pressed("parry"):
        action_parry()
    
func process_movement(delta):		
    if not dash_active_timer.is_stopped():
        current_velocity = dash_direction*PLAYER_DASH_SPEED
        
    else:
        movement_vector = movement_vector*PLAYER_MAX_SPEED
        
        if movement_vector.length() > 0:
            current_velocity = current_velocity.linear_interpolate(movement_vector, PLAYER_ACCELERATION)
        else:
            current_velocity = current_velocity.linear_interpolate(Vector2.ZERO, PLAYER_DECELERATION)
    
    global_position += current_velocity*delta
    clamp_position()
        
func process_rotation(delta):
    # The player's sprite doesn't just snap to the desired angle, it instead
    # gradually turns at a speed dependent on PLAYER_TURN_SPEED.
    # This is purely visual and does not affect the direction bullets are fired in.
    if aim_vector.length() > 0:
        current_aim = aim_vector
    
    # This calculates the desired angle based on joystick/cursor position, as
    # well as the shortest route to achieve that angle
    var desired_angle = int(rad2deg(current_aim.angle()))
    var current_angle = int(global_rotation_degrees)
    var difference = (desired_angle - current_angle + 540) % 360 - 180
      
    if abs(difference) < PLAYER_TURN_SPEED:
        global_rotation_degrees = desired_angle
    elif difference < 0:
        global_rotation -= PLAYER_TURN_SPEED*delta
    else:
        global_rotation += PLAYER_TURN_SPEED*delta

func clamp_position():
    var screen_rect = the_game.get_visible_world_rect()
    global_position.x = clamp(global_position.x, screen_rect[0].x, screen_rect[1].x)
    global_position.y = clamp(global_position.y, screen_rect[0].y, screen_rect[1].y)
    
func get_movement_vector() -> Vector2:
    var move_vec : Vector2 = Vector2()
    
    if Input.is_action_pressed("move_up"):
        move_vec.y -= Input.get_action_strength("move_up")
    if Input.is_action_pressed("move_down"):
        move_vec.y += Input.get_action_strength("move_down")
    if Input.is_action_pressed("move_left"):
        move_vec.x -= Input.get_action_strength("move_left")
    if Input.is_action_pressed("move_right"):
        move_vec.x += Input.get_action_strength("move_right")
        
    if move_vec.length() < JOY_LEFT_DEADZONE:
        return Vector2.ZERO
        
    return move_vec

func get_aim_joystick() -> Vector2:
    if aimed_mouse:
        aimed_mouse = false
        return aim_vector
        
    var aim_vec : Vector2 = Vector2()
    
    if Input.is_action_pressed("aim_up"):
        aim_vec.y -= Input.get_action_strength("aim_up")
    if Input.is_action_pressed("aim_down"):
        aim_vec.y += Input.get_action_strength("aim_down")
    if Input.is_action_pressed("aim_left"):
        aim_vec.x -= Input.get_action_strength("aim_left")
    if Input.is_action_pressed("aim_right"):
        aim_vec.x += Input.get_action_strength("aim_right")
    
    if aim_vec.length() < JOY_RIGHT_DEADZONE:
        return Vector2.ZERO
        
    interface.enable_joystick_cursor()
    return aim_vec.normalized()
 
func invincibility_sprite_flicker():
    if not iframes_timer.is_stopped():
        if flicker_timer.is_stopped():
            $PlayerSprite.visible = not $PlayerSprite.visible
            flicker_timer.start(PLAYER_FLICKER_TIME)
        
    else:
        $PlayerSprite.visible = true
      
func update_crosshair_position():
    var angle_vec = Vector2(cos(global_rotation), sin(global_rotation))
    joy_crosshair.global_position = global_position + angle_vec*JOY_CROSSHAIR_DISTANCE
    joy_crosshair.global_rotation = 0

func get_crosshair_position():
    return joy_crosshair.global_position
    
func update_barrier_sprite():
    $BarrierSprite.visible = not powerup_timers[1].is_stopped()
    
func update_parry_sprite():
    $ParrySprite.visible = not parry_active_timer.is_stopped()
    $ParrySprite.rotation_degrees = 360.0*(parry_active_timer.get_time_left()/PLAYER_PARRY_DURATION)
    $ParrySprite.position = Vector2(-27.5, -27.5).rotated($ParrySprite.rotation)
    
# Helpers   
func attempt_collect_powerups():
    var areas = collection_radius.get_overlapping_areas()
    if not areas.empty():
        var powerup = areas[0].get_parent()
        
        if powerup.get_parent() != null:
            powerup_timers[powerup.powerup_type].start(POWERUP_DURATION)
            
        interface.create_buff_icon(powerup.powerup_type)
        powerup.queue_free()
        
func cancel_powerup(powerup : int):
    powerup_timers[powerup].stop()
    
func has_powerup(powerup : int) -> bool:
    return not powerup_timers[powerup].is_stopped()

func get_powerup_time_remaining(powerup : int) -> float:
    return powerup_timers[powerup].get_time_left()

func take_damage(damage_amount : int):
    if not iframes_timer.is_stopped() or damage_amount == 0:
        return
        
    if has_powerup(1):
        cancel_powerup(1)
    
    elif not parry_active_timer.is_stopped():
        pass
    
    else:
        current_health -= damage_amount
        
    current_health = int(max(0, current_health))
        
    iframes_timer.start(PLAYER_INVINCE_TIME)
    flicker_timer.start(PLAYER_FLICKER_TIME)
       
func is_alive() -> bool:
    return current_health > 0
    
# Actions
func action_primary_fire():
    if current_aim.length() == 0:
        return
        
    var bullet_obj = bullet_scene.instance()
    get_parent().add_child(bullet_obj)
    
    bullet_obj.set_initial_position(global_position)
    bullet_obj.set_initial_velocity(current_aim)
    bullet_obj.set_projectile_owner(self)
    
    pfire_timer.start(PRIMARY_FIRE_CD)

func action_dash():
    if not dash_active_timer.is_stopped() or not dash_cd_timer.is_stopped():
        return
        
    var direction = movement_vector.normalized()
    
    if direction.length() == 0:
        return
        
    dash_direction = direction
    dash_active_timer.start(PLAYER_DASH_DURATION)
    dash_cd_timer.start(PLAYER_DASH_COOLDOWN)
    
func action_parry():
    if not parry_active_timer.is_stopped() or not parry_cd_timer.is_stopped():
        return
        
    parry_active_timer.start(PLAYER_PARRY_DURATION)
    parry_cd_timer.start(PLAYER_PARRY_COOLDOWN)
