extends Node
class_name TopDownN2DMoviment

@export var ref_agent : Node2D
@export_category("Input Actions Names")
@export var move_right := "move_right"
@export var move_left := "move_left"
@export var move_up := "move_up"
@export var move_down := "move_down"
@export_category("Agent Behaviours")
@export var allow_diagonal := true
@export_range(5, 1000, 5) var max_speed := 200
@export_range(0.01, 1.0, 0.01) var accel_factor := .25
@export_range(0.01, 1.0, 0.01) var deaccel_factor := .25
@export_category("Sprite Behaviour")
@export var agent_sprite : Node2D
@export var rotate_to_direction := false
@export var reset_rotation_on_stop := false
@export_range(0.01, 1.0, 0.01) var rotation_speed := .25
@export var default_angle = 90

var _accel_vec := Vector2()
var _agent_sprite_start_rot = 0.0

var velocity := Vector2()
var direction = Vector2()

func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	
	if ref_agent == null:
		push_warning("The variable ref_agent is null")
		return
		
	if (move_left not in InputMap.get_actions() or
		move_right not in InputMap.get_actions() or
		move_up not in InputMap.get_actions() or
		move_down not in InputMap.get_actions()):
		push_warning("One or more actions doesn't exist")
		return

		
	if agent_sprite != null:
		_agent_sprite_start_rot = agent_sprite.rotation
		
		
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
		
func _physics_process(delta):
	Input.is_action_pressed("ui_up")
	
	direction.x = Input.get_axis(move_left, move_right)
	direction.y = Input.get_axis(move_up, move_down)
	
	if (direction ==  Vector2(1 ,1) or direction == Vector2(-1 ,1) or
		direction ==  Vector2(1 ,-1) or direction == Vector2(-1 ,-1)) and not allow_diagonal:
		direction = Vector2()
	direction = direction.normalized()
	if direction.length() > 0:
		_accel_vec = lerp(_accel_vec, direction * max_speed, accel_factor)
		
		if agent_sprite != null and rotate_to_direction:
			agent_sprite.rotation = lerp_angle(
												agent_sprite.rotation,
												direction.angle() +
												_agent_sprite_start_rot
												- deg_to_rad(default_angle),
												rotation_speed
												)

	else:
		if agent_sprite != null and reset_rotation_on_stop:
			agent_sprite.rotation = lerp_angle(
											agent_sprite.rotation,
											_agent_sprite_start_rot,
											rotation_speed
											)
		_accel_vec = lerp(_accel_vec, Vector2(), deaccel_factor)
		
	velocity = _accel_vec
	ref_agent.position += velocity * delta
	direction = Vector2()
