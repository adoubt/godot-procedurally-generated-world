extends Node3D

@export var player_path: NodePath  # Путь к игроку

func _ready():
	# Получаем игрока и его позицию
	var player = get_node(player_path)
	if not player:
		print("Игрок не найден!")
		return
	var player_position = player.global_transform.origin
	var spawn_position = player_position + Vector3(2, 0, 0)  # Смещаем на 2 метра

	# Создаём физическое тело с анимациями
	var body = create_physics_body(spawn_position)
	add_child(body)

# Функция создания физического тела
func create_physics_body(spawn_pos: Vector3) -> RigidBody3D:
	var body = RigidBody3D.new()
	body.position = spawn_pos

	# Добавляем коллизию
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()  # Простая коробка для коллизии
	collision_shape.shape = box_shape
	body.add_child(collision_shape)

	# Меш для тела
	var skeleton_mesh = create_skeleton_mesh()
	body.add_child(skeleton_mesh)

	# Создаём анимации для моба
	var anim_player = AnimationPlayer.new()
	body.add_child(anim_player)

	# Пример проигрывания анимации
	anim_player.play("Idle")  # Можно переключать анимации по состояниям (ходьба, атака)

	return body

# Функция создания лоу-поли скелета с примитивами
func create_skeleton_mesh() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()

	# Тело
	var body = create_cube(Vector3(0, 1, 0), Vector3(0.5, 1, 0.3))
	mesh_instance.add_child(body)

	return mesh_instance

# Функция создания куба (тело)
func create_cube(position: Vector3, size: Vector3) -> MeshInstance3D:
	var mesh = BoxMesh.new()
	mesh.size = size
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	return mesh_instance
