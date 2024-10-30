extends Weapon

func _ready():
	max_clip = 15;
	reload_speed = 0.75;
	turn_cooldown_skip_count = 0;
	max_ammo = max_clip*3;
	ammo = max_ammo;
	chamber_bonus = 1;
	clip = max_clip;

var shot = preload("res://actors/character/guns/shots/simple_shot.tscn");
@rpc("authority", "call_local", "reliable", 4) func _discharge(dischage_transform:Transform2D):
	for i in range(2):
		var p = (i*2) - 1;
		
		
		var bullet = shot.instantiate();
		self.add_child(bullet, true);
		bullet.damage = ProjectSettings.get_setting("game/bullet/duel_pistol_damage", 0);
		bullet.meta_data = {
			"attacker" = get_parent().get_parent()
		};
		bullet.global_transform = dischage_transform;
		bullet.global_position += dischage_transform.y*17*p;
		bullet.shoot();

func get_weapon_string() -> String:
	return "DP";

func get_weapon_animation_string() -> String:
	if reloading:
		if reload_timer < 0.25:
			return "DPReloading3"
		if reload_timer < 0.75:
			return "DPReloading2"
		return "DPReloading1";
	return "DP";

func get_ammo_texture() -> Texture2D:
	return preload("res://resource/img/ammo/duel_pistol_ammo.tres");

func get_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/pistol.mp3") as AudioStream;

func get_equip_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/pistolequip.tres") as AudioStream;
