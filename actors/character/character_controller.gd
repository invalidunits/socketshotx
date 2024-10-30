extends Node
class_name CharacterController;

func get_movement_vector(character:Character) -> Vector2:
	return Vector2.ZERO;

func get_shooting_vector(character:Character) -> Vector2:
	return Vector2.ZERO;

func is_using_power(character:Character) -> bool:
	return false;

func is_using_special(character:Character) -> bool:
	return false;

func is_using_reload(character:Character) -> bool:
	return false;

func get_target_weapon(character:Character) -> int:
	return 0;
