extends Node2D
class_name Weapon;


@export var max_clip = 5;
@export var max_ammo = 15;
@export var reload_speed = 1;
@export var weapon_cooldown = 0.2;
@export var chamber_bonus = 0;

@export var preperation_speed = 1;
@export var prepare := false;

@onready var clip = max_clip;
@onready var ammo = max_ammo;
@onready var reload_timer = 0;
@onready var cooldown = 0;
@onready var prep = 0;

@onready var reloading = false;
@onready var weapon = 0;
@onready var recoil = 0;

@export var turn_cooldown_skip_count := 3;
@onready var turn_cooldown_skips := turn_cooldown_skip_count;


@rpc("authority", "call_local", "reliable", 4) func _discharge(_dischage_transform:Transform2D):
	pass;

func get_weapon_string() -> String: return "";
func get_weapon_animation_string() -> String: return "";
func get_ammo_texture() -> Texture2D: return null;
func get_equip_sound_effect() -> AudioStream: return null;
func get_weapon_metadata() -> Dictionary: return {};


func has_equiped() -> bool:
	return get_parent().get_parent().get_weapon(get_parent().get_parent().weapon) == self;

func is_shooting() -> bool:
	return has_equiped() && get_parent().get_parent().shooting;

func reload():
	if ammo <= 0 || clip >= max_clip:
		# Play sound effect
		return;
	if reloading:
		return;
	reload_timer = 0;
	reloading = true;

var last_direction := Vector2.ZERO;

func _weapon_update(delta:float, direction=Vector2.ZERO):
	var just_turned = false;
	if !last_direction.is_equal_approx(direction):
		last_direction = direction;
		just_turned = true;
	
	
	cooldown -= delta;
	if reloading:
		reload_timer += reload_speed*delta;
		if reload_timer >= 1:
			var increase = max_clip - clip;
			if increase > 0:
				if clip > 0:
					clip += chamber_bonus;
				ammo -= increase;
				clip += increase;
				if ammo < 0:
					clip += ammo;
					ammo = 0;
			
			reloading = false;
			reload_timer = 0;
		else:
			return;
	
	if is_shooting() and not direction.is_zero_approx():
		if clip <= 0: 
			reload();
			return;
		
		# An old "glitch" ported to a new engine.
		# This makes melee weapons incredibly OP if you know the tech.
		if just_turned && turn_cooldown_skips > 0:
			turn_cooldown_skips -= 1;
		else:
			if cooldown > 0:
				return;
			turn_cooldown_skips = turn_cooldown_skip_count;
			
		if prepare && prep < 1:
			prep += preperation_speed*delta;
			if prep >= 1:
				prep = 1;
			else:
				return;
		if can_shoot():
			discharge();
	else:
		prep = 0;

func can_shoot() -> bool:
	var query = PhysicsPointQueryParameters2D.new();
	query.position = global_position;
	return get_world_2d().direct_space_state.intersect_point(query).is_empty();


func discharge():
	clip -= 1;
	cooldown = weapon_cooldown;
	prep = 0;

	
	rpc("_discharge", global_transform);
