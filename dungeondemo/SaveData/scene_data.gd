extends Resource
class_name SceneData

@export_storage var player_position : Vector2
@export_storage var player_hp : int
@export_storage var player_max_hp : int
@export_storage var player_direction: Vector2

@export_storage var enemy_array:Array[PackedScene]
@export_storage var mirror_array:Array[PackedScene]
@export_storage var chest_array:Array[PackedScene]
@export_storage var magent_array:Array[PackedScene]

@export_storage var scene_path:String
