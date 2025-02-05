extends Node

const MAP_SIZE = 128  # Размер сетки (количество полигонов)
const TILE_SIZE = 2.0  # Размер одного квадрата (чем больше, тем менее детализирован рельеф)
const HEIGHT_MULTIPLIER = 20.0  # Максимальная высота гор

var noise = FastNoiseLite.new()  # Генератор шума
var player: Node3D  # Ссылка на игрока
var terrain_mesh: MeshInstance3D  # Меш рельефа
var collision: StaticBody3D  # Коллизия земли

func _ready():
	player = get_node("../Player")  # Получаем ссылку на игрока

	# Настройки шума
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.005
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	
	generate_terrain()
	position_player()

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var highest_point = -INF  # Для определения точки спавна
	var spawn_position = Vector3.ZERO
	
	for x in range(MAP_SIZE):
		for z in range(MAP_SIZE):
			var world_x = x * TILE_SIZE
			var world_z = z * TILE_SIZE
			var height = noise.get_noise_2d(world_x, world_z) * HEIGHT_MULTIPLIER

			if height > highest_point:
				highest_point = height
				spawn_position = Vector3(world_x, height + 2.0, world_z)  # +2, чтобы игрок не застревал
			
			var v1 = Vector3(world_x, height, world_z)
			var v2 = Vector3(world_x + TILE_SIZE, noise.get_noise_2d(world_x + TILE_SIZE, world_z) * HEIGHT_MULTIPLIER, world_z)
			var v3 = Vector3(world_x, noise.get_noise_2d(world_x, world_z + TILE_SIZE) * HEIGHT_MULTIPLIER, world_z + TILE_SIZE)
			var v4 = Vector3(world_x + TILE_SIZE, noise.get_noise_2d(world_x + TILE_SIZE, world_z + TILE_SIZE) * HEIGHT_MULTIPLIER, world_z + TILE_SIZE)

			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v3)

			st.add_vertex(v2)
			st.add_vertex(v4)
			st.add_vertex(v3)

	st.generate_normals()
	var mesh = st.commit()

	# Создаем и добавляем меш
	terrain_mesh = MeshInstance3D.new()
	terrain_mesh.mesh = mesh
	add_child(terrain_mesh)

	# Создаем и добавляем коллизию
	collision = StaticBody3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	collision.add_child(shape)
	add_child(collision)

	player.position = spawn_position  # Устанавливаем игрока на самый высокий участок

func position_player():
	player.position.y += 5.0  # Поднимаем игрока немного, чтобы избежать залипания
