extends Weapon;

func _ready():
	weapon_cooldown = 1;
	max_clip = 10;
	max_ammo = 0;
	turn_cooldown_skip_count = 0;
	reload_speed = 0.526;
	ammo = max_ammo;
	clip = max_clip;
	prepare = true;
	preperation_speed = 0.333;
	
func _enter_tree():
	aim_coroutine();

var aim_visible = false;

func aim_coroutine():
	while true:
		if is_queued_for_deletion():
			return;
		if !is_inside_tree():
			return;
		
		if is_shooting():
			await  get_tree().create_timer(0.1).timeout;
			aim_visible = !aim_visible;
			queue_redraw();
		else:
			aim_visible = false;
			queue_redraw();
			while !is_shooting():
				if is_queued_for_deletion():
					return;
				if !is_inside_tree():
					return;
				await get_tree().process_frame;
	pass;



var lastprep = 0;
func _weapon_update(delta:float, direction=Vector2.ZERO):
	super(delta);
	var deltaprep = prep-lastprep;
	
	var advance = deltaprep*$AnimationPlayer.get_animation("LaserPerpare").length;
	if !is_shooting() || cooldown > 0 || advance < 0:
		lastprep = 0;
		$AnimationPlayer.stop(false);
		$AudioStreamPlayer2D.stop();
	else:
		if !$AnimationPlayer.is_playing():
			$AudioStreamPlayer2D.play();
			$AnimationPlayer.play("LaserPerpare");
		
		if advance != 0:
			$AnimationPlayer.advance(advance);
	lastprep = prep;
func get_weapon_string() -> String:
	return "laser";

func get_weapon_animation_string() -> String:
	return "laser";

var shot = preload("res://actors/character/guns/shots/laser_shot.tscn");

func _draw():
	if aim_visible:
		var len = ProjectSettings.get_setting(
			"game/bullet/laser_length", 22.0
		)*ProjectSettings.get_setting("game/measurement/gameplay_unit", 75);
		draw_line(Vector2.ZERO, Vector2.RIGHT*len, Color.RED, 1.0);


@rpc("authority", "call_local", "reliable", 4) func _discharge(dischage_transform:Transform2D):
	var bullet = shot.instantiate();
	self.add_child(bullet);
	bullet.damage = 300;
	bullet.meta_data = {
		"attacker" = get_parent().get_parent()
	};
	bullet.global_transform = dischage_transform;
	

	
	
	bullet.shoot();

func get_sound_effect() -> AudioStream:
	return preload("res://resource/sfx/laserDischarge.mp3") as AudioStream;
