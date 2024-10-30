extends Weapon;

func _ready():
	max_clip = 15;
	chamber_bonus = 1;
	turn_cooldown_skip_count = 0;
	max_ammo = INF;
	ammo = max_ammo;
	clip = max_clip;

var shot = preload("res://actors/character/guns/shots/simple_shot.tscn");
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
	return "pistol";

func get_weapon_animation_string() -> String:
	if reloading:
		if reload_timer < 0.4:
			return ""
		if reload_timer < 0.6:
			return "pistolReloading4"
		if reload_timer < 0.8:
			return ""
		if reload_timer < 1.0:
			return "pistolReloading2"
		if reload_timer < 1.2:
			return "pistolReloading1"
	return "";

func get_ammo_texture() -> Texture2D:
	return preload("res://assets/img/ammo/pistol_ammo.tres");

func get_equip_sound_effect() -> AudioStream:
	return preload("res://assets/sfx/pistolequip.tres") as AudioStream;
