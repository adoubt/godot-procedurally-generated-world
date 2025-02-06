extends Node

const MAP_SIZE = 128  # Размер сетки (количество полигонов)
const TILE_SIZE = 1  # Размер одного квадрата (чем больше, тем менее детализирован рельеф)
const HEIGHT_MULTIPLIER = 12.0  # Максимальная высота гор
const MIN_HEIGHT = 3.0  # Минимальная высота рельефа
const MAX_HEIGHT = 15.0  # Максимальная высота рельефа
const WATER_LEVEL = 4.0   # Уровень воды

var noise = FastNoiseLite.new()  # Генератор шума
var island_noise = FastNoiseLite.new()  # Шум для островков
var player: Node3D  # Ссылка на игрока
var terrain_mesh: MeshInstance3D  # Меш рельефа
var collision: StaticBody3D  # Коллизия земли
var water_mesh: MeshInstance3D  # Водная поверхность

func _ready():
	player = get_node("../Player")  # Получаем ссылку на игрока
	
	# Настройки шума рельефа (мягкий болотистый рельеф)
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.005  # Очень низкая частота → плавные изменения
	noise.fractal_octaves = 2  
	noise.fractal_lacunarity = 1.8  
	noise.fractal_gain = 0.4  
	noise.seed = randi()
	
	# Настройки шума для островков
	island_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	island_noise.frequency = 0.02  # Делаем ямы немного реже
	island_noise.fractal_octaves = 3  
	island_noise.fractal_lacunarity = 2.2  
	island_noise.seed = noise.seed + 200 
	
	generate_terrain()
	generate_water()
	position_player()
	add_sunlight()
	
func get_height(x, z):
	var base_noise = noise.get_noise_2d(x, z) * 3.0 + 5.0  
	
	var hole_factor = island_noise.get_noise_2d(x, z)  

	if hole_factor < -0.3:  
		base_noise -= abs(hole_factor) * 15.0  

	# Усредняем высоту с соседними точками
	var avg_height = (get_safe_height(x-1, z) + get_safe_height(x+1, z) + get_safe_height(x, z-1) + get_safe_height(x, z+1) + base_noise) / 5.0

	return max(avg_height, 0)

# Функция, чтобы не выходить за границы карты
func get_safe_height(x, z):
	if x < 0 or x >= MAP_SIZE or z < 0 or z >= MAP_SIZE:
		return 5.0  # Высота по умолчанию
	return noise.get_noise_2d(x, z) * 3.0 + 5.0
		
func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var highest_point = -INF  
	var spawn_position = Vector3.ZERO

	for x in range(MAP_SIZE):
		for z in range(MAP_SIZE):
			var world_x = x * TILE_SIZE
			var world_z = z * TILE_SIZE
			var height = get_smoothed_height(world_x, world_z)  # <-- Тут заменили вызов шума

			var island_factor = island_noise.get_noise_2d(world_x, world_z)

			# Островки немного поднимаются над водой
			if height < WATER_LEVEL and island_factor > 0.2:
				height = WATER_LEVEL + 2.0

			# Ограничиваем высоту
			height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)

			if height > highest_point:
				highest_point = height
				spawn_position = Vector3(world_x, height + 2.0, world_z)

			# Получаем соседние вершины с учетом сглаженной высоты
			var v1 = Vector3(world_x, height, world_z)
			var v2 = Vector3(world_x + TILE_SIZE, get_smoothed_height(world_x + TILE_SIZE, world_z), world_z)
			var v3 = Vector3(world_x, get_smoothed_height(world_x, world_z + TILE_SIZE), world_z + TILE_SIZE)
			var v4 = Vector3(world_x + TILE_SIZE, get_smoothed_height(world_x + TILE_SIZE, world_z + TILE_SIZE), world_z + TILE_SIZE)

			var color = get_color_for_height(height)

			st.set_color(color)
			st.add_vertex(v1)
			st.set_color(color)
			st.add_vertex(v2)
			st.set_color(color)
			st.add_vertex(v3)

			st.set_color(color)
			st.add_vertex(v2)
			st.set_color(color)
			st.add_vertex(v4)
			st.set_color(color)
			st.add_vertex(v3)

	var mesh = st.commit()

	# Создаем и добавляем меш
	terrain_mesh = MeshInstance3D.new()
	terrain_mesh.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.3, 0.1)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	terrain_mesh.material_override = mat

	add_child(terrain_mesh)

	# Создаем и добавляем коллизию
	collision = StaticBody3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	collision.add_child(shape)
	add_child(collision)

	player.position = spawn_position  # Устанавливаем игрока на самый высокий участок

func get_smoothed_height(x, z):
	var h = get_height(x, z)
	h += get_height(x - 1, z) 
	h += get_height(x + 1, z) 
	h += get_height(x, z - 1) 
	h += get_height(x, z + 1)
	return h / 5.0  # Усредняем высоту

func get_color_for_height(height: float) -> Color:
	if height < WATER_LEVEL + 1.0:
		return Color(0.2, 0.4, 0.1)  # Грязно-зеленый для болот
	elif height < WATER_LEVEL + 5.0:
		return Color(0.3, 0.5, 0.2)  # Трава
	elif height < MAX_HEIGHT * 0.5:
		return Color(0.5, 0.4, 0.2)  # Земля
	else:
		return Color(0.7, 0.7, 0.7)  # Камни

func generate_water():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(MAP_SIZE):
		for z in range(MAP_SIZE):
			var world_x = x * TILE_SIZE
			var world_z = z * TILE_SIZE
			
			var v1 = Vector3(world_x, WATER_LEVEL, world_z)
			var v2 = Vector3(world_x + TILE_SIZE, WATER_LEVEL, world_z)
			var v3 = Vector3(world_x, WATER_LEVEL, world_z + TILE_SIZE)
			var v4 = Vector3(world_x + TILE_SIZE, WATER_LEVEL, world_z + TILE_SIZE)

			
			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v3)

			st.add_vertex(v2)
			st.add_vertex(v4)
			st.add_vertex(v3)
	
	st.generate_normals()
	var mesh = st.commit()
	
	water_mesh = MeshInstance3D.new()
	water_mesh.mesh = mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.15, 0.08, 0.75)
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Включаем рендеринг с двух сторон

	water_mesh = MeshInstance3D.new()
	water_mesh.mesh = mesh
	water_mesh.material_override = material  # Применяем материал

	add_child(water_mesh)


func position_player():
	player.position.y += 5.0  # Поднимаем игрока немного, чтобы избежать залипания

func add_sunlight():
	var light = DirectionalLight3D.new()
	light.light_energy = 0.7  # Интенсивность света
	light.rotation_degrees = Vector3(-45, -45, 0)  # Угол падения света
	light.shadow_enabled = true  # Включить тени
	add_child(light)
