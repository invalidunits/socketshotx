extends Node2D
class_name GunShot

@export var damage:float = 25;
@export var meta_data:Dictionary = {};

func get_colliding_hits() -> Array[Dictionary]:
	return [];

func _shoot() -> void:
	pass; 

func shoot():
	await _shoot();
	if is_multiplayer_authority():
		var hits = get_colliding_hits();
		print(hits);
		for hit in hits:
			var hit_data = hit.duplicate();
			hit_data.merge(meta_data);
			
			assert(hit.get("object"));
			if hit.get("object").has_method("inflict"):
				hit.get("object").call("inflict", 
					damage * hit.get("dmg_multi", 1.0), hit_data);
	fade_away();


@rpc() func fade_away():
	pass;
