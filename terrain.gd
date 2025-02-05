extends Node3D

const MAP_SIZE = 64  # Размер сетки (количество полигонов)
const TILE_SIZE = 2.0  # Размер одного квадрата (чем больше, тем менее детализирован рельеф)
const HEIGHT_MULTIPLIER = 20.0  # Максимальная высота гор

var noise = FastNoiseLite.new()  # Генератор шума
var player: Node  # Ссылка на игрока
var generated_cubes  # Словарь для хранения сгенерированных кубов

func _ready():
	generated_cubes = {}  # Инициализация словаря сгенерированных кубов
	player = get_node("%Player")  # Получаем ссылку на объект игрока
	
	# Настройки шума
	noise.noise_type = FastNoiseLite.TYPE_PERLIN  # Используем Перлин-шум
	noise.frequency = 0.01  # Частота шума (мелкие или крупные детали)
	noise.fractal_octaves = 5  # Количество "деталей"
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

	generate_terrain()  # Генерируем рельеф

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Создаем вершины сетки
	for x in range(MAP_SIZE):
		for z in range(MAP_SIZE):
			var world_x = x * TILE_SIZE
			var world_z = z * TILE_SIZE
			var height = noise.get_noise_2d(world_x, world_z) * HEIGHT_MULTIPLIER

			# Добавляем вершины (четыре угла квадрата)
			var v1 = Vector3(world_x, height, world_z)
			var v2 = Vector3(world_x + TILE_SIZE, noise.get_noise_2d(world_x + TILE_SIZE, world_z) * HEIGHT_MULTIPLIER, world_z)
			var v3 = Vector3(world_x, noise.get_noise_2d(world_x, world_z + TILE_SIZE) * HEIGHT_MULTIPLIER, world_z + TILE_SIZE)
			var v4 = Vector3(world_x + TILE_SIZE, noise.get_noise_2d(world_x + TILE_SIZE, world_z + TILE_SIZE) * HEIGHT_MULTIPLIER, world_z + TILE_SIZE)

			# Создаем два треугольника на один квадрат
			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v3)

			st.add_vertex(v2)
			st.add_vertex(v4)
			st.add_vertex(v3)

	# Завершаем создание меша
	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
