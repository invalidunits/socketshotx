extends CharacterPower

@onready var throw_force = ProjectSettings.get_setting(&"game/player/throw_force", 1875);
@onready var weights: Node2D = $"../../Weights"

func get_priority() -> int:
	var controller = character.controller;
	if controller:
		if character.input_movement:
			return 2;
	return -1;

func get_cooldown(state:PhysicsDirectBodyState2D) -> float:
	return 0.0;
	
func can_activate() -> bool:
	return weights.get_child_count() > 0;
	
func activate(state:PhysicsDirectBodyState2D) -> void:
	var weight = weights.get_child(0);
	weight.rpc("throw_weight", character.get_parent().get_path(), throw_force*state.transform.x);

	
	
func use_texture() -> Texture:
	return null; 

func get_power_name() -> StringName:
	return &"Boost Thrusters"

func get_power_cost() -> float:
	return ProjectSettings.get_setting(&"game/player/boost_energy_cost", 99);
