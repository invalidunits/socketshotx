extends Weapon;

func _ready():
	weapon_cooldown = 0.08;
	max_clip = 60;
	max_ammo = 180;
	turn_cooldown_skip_count = 0;
	reload_speed = 0.526;
	ammo = max_ammo;
	clip = max_clip;

var shot = preload("res://actors/character/guns/shots/simple_shot.tscn");
@rpc("authority", "call_local", "reliable", 4) func _discharge(dischage_transform:Transform2D):
	var bullet = shot.instantiate();
	self.add_child(bullet);
	bullet.damage = ProjectSettings.get_setting("game/bullet/machine_gun_damage", 0);
	bullet.meta_data = {
		"attacker" = get_parent().get_parent()
	};
	bullet.global_transform = dischage_transform;
	bullet.shoot();

func get_weapon_string() -> String:
	return "MG";

func get_weapon_animation_string() -> String:
	if reloading:
		if reload_timer < 0.263158:
			return "MGReloading4"
		if reload_timer < 0.324561:
			return "MGReloading5"
		if reload_timer < 0.473684:
			return "MGReloading4"
		if reload_timer < 0.570175:
			return "MGReloading1"
		if reload_timer < 0.666667:
			return "MGReloading2"
		if reload_timer < 0.815789:
			return "MGReloading3"
		if reload_timer < 0.912281:
			return "MGReloading2"
		return "MGReloading1"
	
	return "MG";

func get_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/mgShot.mp3") as AudioStream;

func get_equip_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/MGequip.mp3") as AudioStream;

func get_ammo_texture() -> Texture2D:
	return preload("res://resource/img/ammo/machine_gun_ammo.tres");
