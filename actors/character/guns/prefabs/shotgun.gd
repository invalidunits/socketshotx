extends Weapon;

func _ready():
	max_clip = 6;
	max_ammo = 18;
	weapon_cooldown = 0.63;
	turn_cooldown_skip_count = 3;
	reload_speed = 0.5;
	ammo = max_ammo;
	clip = max_clip;

var shot = preload("res://actors/character/guns/shots/shotgun_shot.tscn");
@rpc("authority", "call_local", "reliable", 4) func _discharge(dischage_transform:Transform2D):
	var bullet = shot.instantiate();
	self.add_child(bullet);
	bullet.damage = ProjectSettings.get_setting("game/bullet/pistol_damage", 0);
	bullet.meta_data = {
		"attacker" = get_parent().get_parent()
	};
	bullet.global_transform = dischage_transform;
	bullet.shoot();

func get_weapon_string() -> String:
	return "SG";

func get_weapon_animation_string() -> String:
	if reloading:
		
		if reload_timer < 0.3:
			return "SG"
		if reload_timer < 0.5:
			return "SGCock"
		if reload_timer < 0.7:
			return "SG"
	if cooldown > 0:
		if cooldown > 0.2:
			return "SG"
		if cooldown > 0.4:
			return "SGCock"
		if cooldown > 0.6:
			return "SG"
	return "SG";

func get_ammo_texture() -> Texture2D:
	return preload("res://resource/img/ammo/shotgun_ammo.tres");

func get_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/pistol.mp3") as AudioStream;

func get_equip_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/pistolequip.tres") as AudioStream;
