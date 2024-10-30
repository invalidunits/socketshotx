class_name CharacterItem
extends Area2D

@export var cooldown:float = 0.0;
@export var cooldown_timer:float = 0.0;

func can_equip(body:Character):
	return true;

func _process(delta):
	if cooldown_timer > 0:
		$Label.visible = true;
		$AnimationPlayer.process_mode = Node.PROCESS_MODE_DISABLED;
		$Label.text = String.num(floor(cooldown_timer), 0);
		$Texture/Light.modulate = Color.TRANSPARENT;
		$Texture.modulate = Color.GRAY;
		
	else:
		$Texture.self_modulate = Color.WHITE;
		$AnimationPlayer.process_mode = Node.PROCESS_MODE_INHERIT;
		$Label.visible = false;
		$Label.text = "";
		$Texture.modulate = Color.WHITE;
	
	cooldown_timer -= delta;


func _entered(body:Character):
	pass


func _on_body_entered(body):
	if !is_multiplayer_authority():
		return;
		
	print("1")
	if body is Character && (cooldown_timer < 0):
		print("2")
		if can_equip(body):
			print("3")
			cooldown_timer = cooldown;
			_entered(body);
