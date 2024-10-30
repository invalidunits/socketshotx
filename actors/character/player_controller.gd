extends CharacterController

@export var movement := Vector2.ZERO;
@export var shoot := Vector2.ZERO;
@export var power := false; # Boost and Invis etc...
@export var special := false; # Throwing grenades, Zoom, grapple etc...
@export var target_weapon := 0;
@export var reload := false;


func get_movement_vector(character:Character) -> Vector2:
	return movement;

func get_shooting_vector(character:Character) -> Vector2:
	return shoot;

func is_using_power(character:Character) -> bool:
	return power;

func is_using_special(character:Character) -> bool:
	return special;

func is_using_reload(character:Character) -> bool:
	return reload;

func get_target_weapon(character:Character) -> int:
	return target_weapon;



func _ready():
	if get_parent().name.is_valid_int():
		set_multiplayer_authority(get_parent().name.to_int());
		

func _process(delta):
	if !is_multiplayer_authority():
		return;
	movement = Input.get_vector("player_left", "player_right", "player_up", "player_down");
	shoot = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down");
	power = Input.is_action_pressed("player_power")
	reload = Input.is_action_pressed("shoot_reload");

func _unhandled_key_input(event):
	if event.is_pressed() && !event.is_echo():
		var key = OS.get_keycode_string(event.keycode);
		if key.is_valid_int():
			target_weapon = key.to_int();
