extends Resource
class_name Stats

enum BuffableStats {
	MAX_HEALTH , 
	DEFENSE ,
	ATTACK ,
}

const STAT_CURVES : Dictionary[BuffableStats , Curve] = {
	BuffableStats.MAX_HEALTH : preload("uid://ce2sfc6m8f4j4") ,
	BuffableStats.DEFENSE : preload("uid://bvl757n27m2hs") , 
	BuffableStats.ATTACK : preload("uid://bg1ly677hm6wd")
}

const BASE_LEVEL_XP : float = 100.0

signal health_depleted
signal health_changed(cur_health : float , max_health : float)

@export var base_max_health : float = 100
@export var base_defense : float = 10
@export var base_attack : float = 10
@export var experience : float = 0 : set = _on_experience_set

var level : int :
	# Returns level based on experience
	get() : return floor(max(1.0 , sqrt(experience / BASE_LEVEL_XP) + 0.5))
var current_max_health : float = 100
var current_defense : float = 10
var current_attack : float = 10

var health = 0 : set = _on_health_set

func _init() -> void:
	resource_local_to_scene = true
	
func _setup_local_to_scene() -> void: # Setup stats here
	recalculate_stats()
	health = current_max_health
	print(health)
	
func recalculate_stats() -> void:
	var stat_sample_pos : float = (float(level) / 100.0) - 0.01
	current_max_health = base_max_health * STAT_CURVES[BuffableStats.MAX_HEALTH].sample(stat_sample_pos)
	current_defense = base_defense * STAT_CURVES[BuffableStats.DEFENSE].sample(stat_sample_pos)
	current_attack = base_attack * STAT_CURVES[BuffableStats.ATTACK].sample(stat_sample_pos)
	

func _on_health_set(new_value : float):
	health = clamp(new_value, 0.0 , current_max_health)
	health_changed.emit(health , current_max_health)
	if health <= 0:
		health_depleted.emit()
		
func _on_experience_set(new_value : float) -> void:
	var old_level : int = level
	experience = new_value
	
	if not old_level == level:
		recalculate_stats()
