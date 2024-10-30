extends RigidBody2D
class_name Character;

@onready var player_speed:float = ProjectSettings.get_setting("game/player/speed", 375);
@onready var player_acceleration:float = ProjectSettings.get_setting("game/player/acceleration", 75);
@export var controller:CharacterController = null;


@onready var max_energy:float = ProjectSettings.get_setting("game/player/max_energy", 100);
@export var energy:float = 0.0;
@onready var recharge_cooldown:float = ProjectSettings.get_setting("game/player/energy_recharge_cooldown", 5);
@onready var recharge_speed:float = ProjectSettings.get_setting("game/player/energy_recharge_speed", 33.3333);
@onready var cloak_drain_speed:float = ProjectSettings.get_setting("game/player/cloak_drain_speed", 7.2);
@onready var cloak_drag:float = ProjectSettings.get_setting("game/player/cloak_drag", 0.5);

@onready var heal_factor := 14;
@onready var heal_delay_time := 5.0;

@export_flags("Aliens:2", "Blue:4", "Red:8", "Humans:12", "All:14") var family_layer = 0;
@export_flags("Aliens:2", "Blue:4", "Red:8", "Humans:12", "All:14") var enemy_mask = 0;

const max_health := 100;
const max_shield := 200;
@export var health := 100;

@export var cloaking := false;
@export var shooting := false;
var recharge_delay := 0;
var heal_delay := 0;
var no_energy := false;

signal inflicted(damage, data);

@export var weapon:int = 1;
@export var destory_on_kill = false;
@export var auto_respawn = false;
@export var auto_spawn_group:Array[String] = [];

var all_directions := [
	Vector2.from_angle(0),
	Vector2.from_angle(PI/4),
	Vector2.from_angle(PI/2),
	Vector2.from_angle(PI/2 + PI/4),
	Vector2.from_angle(PI),
	Vector2.from_angle(PI + PI/4),
	Vector2.from_angle(PI + PI/2),
	Vector2.from_angle(TAU - PI/4),
	Vector2.from_angle(TAU),
]

@export var input_movement := Vector2.ZERO;
@export var input_shoot_direction := Vector2.ZERO;
@export var input_power := false; # Boost and Invis etc...
@export var input_special := false; # Throwing grenades, Zoom, grapple etc...
@export var input_target_weapon := 0;
@export var input_reload := false;

@export var just_began_power := false;
@export var just_began_special := false;

func _ready() -> void:
	set_deferred("lock_rotation", true);

func clamp_to_directions(input:Vector2) -> Vector2:
	var dot_product = 0;
	var m = Vector2.ZERO;
	for direction in all_directions:
		if input.dot(direction) > dot_product:
			dot_product = input.dot(direction);
			m = direction;
	return m*input.length();

func spendEnergy(amount:float) -> bool:
	assert(is_multiplayer_authority());
	if no_energy:
		return false;
	if energy <= 0:
		no_energy = true;
		return false;
	energy -= amount;
	if energy > 0:
		recharge_delay = recharge_cooldown;
	else:
		energy = 0;
		no_energy = true;
		recharge_delay = recharge_delay*2;
	return true;

func inflict(infliction, metadata:Dictionary) -> void:
	assert(get_tree().get_multiplayer(get_path()).is_server());
	if is_dead():
		return;
	
	
	health -= infliction;
	if infliction > 0: # We were hurt by the infliction
		heal_delay = heal_delay_time;
	var knockback := Vector2.ZERO;
	var knockback_position := Vector2.ZERO
	
	if infliction > 0:
		knockback = metadata.get("knockback", Vector2.ZERO);
		if metadata.has("hit_position"):
			knockback_position = metadata.get("hit_position", global_position)-global_position
	
	if is_dead() && process_mode != PROCESS_MODE_DISABLED:
		await get_tree().physics_frame;
		var state = PhysicsServer2D.body_get_direct_state(get_rid());
		var corpse = preload("res://actors/character/corpse.tscn").instantiate();
		corpse.velocity = metadata.get("knockback", Vector2.ZERO)*2;
		corpse.global_position = state.transform.origin;
		$Corpses.add_child(corpse);
		
		rpc(&"die");
	else:
		rpc(&"inflict_client", infliction, metadata, knockback, knockback_position);
			

@rpc("any_peer", "call_local") func inflict_client(infliction:float, metadata:Dictionary, knockback:Vector2, knockback_position:Vector2) -> void:
	if get_tree().get_multiplayer(get_path()).get_remote_sender_id() != 1:
		return # Only host can inflict damage.
	inflicted.emit(infliction, metadata);
	apply_impulse(knockback, knockback_position);
	# TODO: blood

func is_dead() -> bool:
	if health <= 0:
		return true;
	return process_mode == PROCESS_MODE_DISABLED;

func visible_to_enemies() -> bool:
	return !is_dead() && !cloaking && visible;

func visible_to_allseeing() -> bool:
	return !is_dead() && visible;

@rpc("authority", "call_local") func _spawn(pos:Vector2):
	await get_tree().physics_frame;
	var state = PhysicsServer2D.body_get_direct_state(get_rid());
	health = 100;
	visible = true;
	cloaking = false;
	process_mode = Node.PROCESS_MODE_INHERIT;
	state.linear_velocity = Vector2.ZERO;
	state.transform.origin = pos;
	global_position = state.transform.origin;

func spawn(spawn_groups:Array[String], pos = null):
	assert(get_tree().get_multiplayer(get_path()).get_remote_sender_id() == 1);
	assert(is_inside_tree());
	
	var spawn_pos = Vector3.ZERO;
	if pos is Vector2:
		spawn_pos = pos;
		
	else:
		var spawn_positions = [];
		for group in spawn_groups:
			spawn_positions.append_array(get_tree().get_nodes_in_group(
				group
			).map( func(node:Node): 
				if node as Node2D:
					return node.global_position;
			));
		spawn_pos = spawn_positions.pick_random();
	rpc("_spawn", spawn_pos)



@rpc("call_local") func die() -> void:
	if get_tree().get_multiplayer(get_path()).get_remote_sender_id() != 1:
		return # Only host can kill a player.
	if health > 0:
		health = 0;
	if destory_on_kill:
		for corpse in $Corpses.get_children():
			corpse.reparent(get_tree().current_scene);
		queue_free();
		
	visible = false;
	cloaking = false;
	process_mode = Node.PROCESS_MODE_DISABLED;

func _process(delta: float) -> void:
	$Display.top_level = true;
	$Display.global_position = global_position;
	$Display.rotation = lerp_angle($Display.rotation, global_rotation, delta*20);
	$Display.cloak = cloaking;
	print(float(health)/float(max_health));
	$Display.health_ratio = clampf(float(health)/float(max_health), 0, 2);
	var weap = get_weapon(weapon);
	if weap:
		$Display.weapon_key = weap.get_weapon_string();
		$Display.weapon_animation_key = weap.get_weapon_animation_string();
	else:
		$Display.weapon_key = "throw1";

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_multiplayer_authority():
		var was_power = input_power;
		var was_special = input_special;
		if is_instance_valid(controller):
			input_movement = clamp_to_directions(controller.get_movement_vector(self)).limit_length();
			input_shoot_direction = clamp_to_directions(controller.get_shooting_vector(self)).normalized();
			input_power = controller.is_using_power(self);
			input_reload = controller.is_using_reload(self);
			input_special = controller.is_using_special(self);
		
		just_began_power = input_power and not was_power;
		just_began_special = input_special and not was_special;

		
	recharge_delay -= state.step;
	if no_energy && energy >= max_energy:
		no_energy = false;
	if recharge_delay <= 0:
		energy = move_toward(energy, max_energy, recharge_speed*state.step);
		recharge_delay = 0;
		
	var pspeed = player_speed;
	if cloaking:
		pspeed *= cloak_drag;
	
	for weight in $Weights.get_children():
		pspeed *= weight.get_weight();
		
	var target_velocity = input_movement*pspeed;
	var direction = Vector2.ZERO;
	state.linear_velocity = state.linear_velocity.move_toward(target_velocity, 
		player_acceleration);
	
	if controller:
		if !input_shoot_direction.is_zero_approx():
			direction = clamp_to_directions(input_shoot_direction);
			shooting = true;
		else:
			direction = input_movement.normalized();
			shooting = false;
	else:
		shooting = false;
	
	state.transform = state.transform.looking_at(global_position + direction);
	_process_powers(state);
	
	if not get_tree().get_multiplayer(get_path()).is_server():
		return;
		
	select_weapon(input_target_weapon);
	var weap = get_weapon(weapon);
	if weap:
		if input_reload:
			weap.reload();
			controller.reload = false;
		weap._weapon_update(state.step, input_shoot_direction);

var power_cooldowns := {}

func _process_powers(state:PhysicsDirectBodyState2D) -> void:
	if !is_multiplayer_authority():
		return;
	for i in power_cooldowns.keys():
		power_cooldowns[i] -= state.step;
	
	if just_began_power:
		var powers = $Powers.get_children();
		powers.sort_custom(func (a, b):
			if not (a as CharacterPower):
				return false;
			if not (b as CharacterPower):
				return false;
			return a.get_priority() > b.get_priority();
		);
		
		var current_power = powers.front() as CharacterPower;
		assert(is_instance_valid(current_power));
		
		if power_cooldowns.get_or_add(hash(get_path_to(current_power)), 0) > 0:
			return;
		if !current_power.can_activate(): 
			return;
		if spendEnergy(current_power.get_power_cost()):
			current_power.activate(state);
			power_cooldowns[hash(get_path_to(current_power))] = 0;

func select_weapon(weap:int = weapon) -> bool:
	assert(get_tree().get_multiplayer(get_path()).is_server());
	if !$Weapons.has_node(String.num(weap)):
		return false;
		
	self.weapon = weap;
	return true;

func get_weapon(index:int) -> Weapon:
	return $Weapons.get_node_or_null(String.num(index));
