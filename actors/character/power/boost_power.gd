extends CharacterPower

@onready var player_boost = ProjectSettings.get_setting("game/player/boost_velocity", 1425);
@onready var player_boost_cost = ProjectSettings.get_setting("game/player/boost_energy_cost", 1);
@export var is_boosting = false;

func get_priority() -> int:
	var controller = character.controller;
	if controller:
		if character.input_movement:
			return 1;
	return -1;

func _physics_process(delta: float) -> void:
	var state := PhysicsServer2D.body_get_direct_state(character.get_rid()); 
	if state.linear_velocity.length() <= owner.player_speed:
		is_boosting = false;

func get_cooldown(state:PhysicsDirectBodyState2D) -> float:
	return 0.0;
	
func can_activate() -> bool:
	return !is_boosting;
	
func _ready() -> void:
	owner.body_entered.connect(_on_collision);
	
func activate(state:PhysicsDirectBodyState2D) -> void:
	is_boosting = true;
	character.cloaking = false;
	var direction = character.clamp_to_directions(character.controller.movement.normalized());
	state.linear_velocity += direction*player_boost;
	
func use_texture() -> Texture:
	return null; 

func get_power_name() -> StringName:
	return &"Boost Thrusters"

func get_power_cost() -> float:
	return ProjectSettings.get_setting(&"game/player/boost_energy_cost", 25);

func _on_collision(body:Node) -> void:
	if not get_tree().get_multiplayer(get_path()).is_server(): return;
	if body is Character:
		if is_boosting:
			rpc(&"hit_character", body.get_path());
