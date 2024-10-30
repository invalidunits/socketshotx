class_name CharacterPower
extends Node

@onready var character: Character = $"../../"

var activated = false;
func get_priority() -> int:
	return -1;
	
func get_power_cost() -> float:
	return 1.0;


func get_cooldown(state:PhysicsDirectBodyState2D) -> float:
	return 0.0;

func can_activate() -> bool:
	return false;

func activate(state:PhysicsDirectBodyState2D):
	return;

func use_texture() -> Texture:
	return null; 

func get_power_name() -> StringName:
	return &"Unknown Power"
