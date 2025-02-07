extends Node

const MAP_SIZE = 256  # Размер сетки (количество полигонов)
const TILE_SIZE = 1  # Размер одного квадрата (чем больше, тем менее детализирован рельеф)
const HEIGHT_MULTIPLIER = 2.0  # Максимальная высота гор
const MIN_HEIGHT = -1.0  # Минимальная высота рельефа
const MAX_HEIGHT = 15.0  # Максимальная высота рельефа
const WATER_LEVEL = 5.0   # Уровень воды

var noise = FastNoiseLite.new()  # Генератор шума
var island_noise = FastNoiseLite.new()  # Шум для островков
var player: Node3D  # Ссылка на игрока
var terrain_mesh: MeshInstance3D  # Меш рельефа
var collision: StaticBody3D  # Коллизия земли
var water_mesh: MeshInstance3D  # Водная поверхность

func _ready():
	player = get_node("../Player")  # Получаем ссылку на игрока
	
	# Настройки шума рельефа (улучшенное формирование суши и воды)
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.001  # Более мягкие переходы
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 2.0  
	noise.fractal_gain = 5 #чем ниже - тем более плоская мапа
	noise.seed = randi()
	
	# Настройки шума для островков
	island_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	island_noise.frequency = 0.07 #площадь островов - 0.003 - большие. 0.03 средние 0,3 маленькие
	island_noise.fractal_octaves = 1 
	island_noise.fractal_lacunarity = 2.0 
	island_noise.fractal_gain = 0.5
	island_noise.seed = noise.seed + 200 
	
	
	add_sunlight()
	generate_terrain()
	generate_water()
	position_player()
	
	
	
func get_height(x, z):
	var base_noise = noise.get_noise_2d(x, z) * 5.0 + 5.0  # Усиливаем контраст
	var hole_factor = island_noise.get_noise_2d(x, z)

	if hole_factor < -0.25:  
		base_noise -= abs(hole_factor) * 2.0  # Ямы становятся менее резкими

	return clamp(base_noise, MIN_HEIGHT, MAX_HEIGHT)

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var highest_point = -INF  
	var spawn_position = Vector3.ZERO
	for x in range(MAP_SIZE):
		for z in range(MAP_SIZE):
			var world_x = x * TILE_SIZE
			var world_z = z * TILE_SIZE
			var height = get_smoothed_height(world_x, world_z)

			# Добавляем островной фактор
			var island_factor = island_noise.get_noise_2d(world_x / 10.0, world_z / 10.0) # нормализуем масштаб шума

			#if height < WATER_LEVEL and island_factor > 0.2:
				#height = WATER_LEVEL + 1.5  # Более мягкий переход от воды к суше
			#if height < WATER_LEVEL and island_factor > 0.2:
				#height = lerp(WATER_LEVEL, WATER_LEVEL + 1.5, island_factor* 0.1)  # Плавный переход

			height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)

			if height > highest_point:
				highest_point = height
				spawn_position = Vector3(world_x, height + 2.0, world_z)
			
			# Создание вершин
			var v1 = Vector3(world_x, height, world_z)
			var v2 = Vector3(world_x + TILE_SIZE, get_smoothed_height(world_x + TILE_SIZE, world_z), world_z)
			var v3 = Vector3(world_x, get_smoothed_height(world_x, world_z + TILE_SIZE), world_z + TILE_SIZE)
			var v4 = Vector3(world_x + TILE_SIZE, get_smoothed_height(world_x + TILE_SIZE, world_z + TILE_SIZE), world_z + TILE_SIZE)
			
			# Вычисляем цвет на основе высоты
			var color = get_color_for_height(height)
			st.set_color(color)

			var normal = (v2 - v1).cross(v3 - v1).normalized()
			if normal.dot(Vector3(0, 1, 0)) < 0:
				normal = -normal  # Переворачиваем нормаль, если она направлена вниз
			st.set_normal(normal)
			
			st.set_uv(Vector2(world_x / TILE_SIZE, world_z / TILE_SIZE)) # Устанавливаем UV-координаты для v1
			st.add_vertex(v1)
			st.set_uv(Vector2((world_x + TILE_SIZE) / TILE_SIZE, world_z / TILE_SIZE)) # Устанавливаем UV-координаты для v2
			st.add_vertex(v2)
			st.set_uv(Vector2(world_x / TILE_SIZE, (world_z + TILE_SIZE) / TILE_SIZE)) # Устанавливаем UV-координаты для v3
			st.add_vertex(v3)
			normal = (v4 - v2).cross(v3 - v2).normalized()
			
			if normal.dot(Vector3(0, 1, 0)) < 0:
				normal = -normal  # Переворачиваем нормаль, если она направлена внизst.set_normal(normal)
			st.set_uv(Vector2((world_x + TILE_SIZE) / TILE_SIZE, world_z / TILE_SIZE))
			st.add_vertex(v2)
			st.set_uv(Vector2((world_x + TILE_SIZE) / TILE_SIZE, (world_z + TILE_SIZE) / TILE_SIZE))
			st.add_vertex(v4)
			st.set_uv(Vector2(world_x / TILE_SIZE, (world_z + TILE_SIZE) / TILE_SIZE))
			st.add_vertex(v3)

	var mesh = st.commit()
	st.generate_normals() # Генерация сглаженных нормалей
	if terrain_mesh:
		remove_child(terrain_mesh)
		terrain_mesh.queue_free()

	terrain_mesh = MeshInstance3D.new()
	terrain_mesh.mesh = mesh
	var material = StandardMaterial3D.new()
	material.vertex_color = true # Включаем использование цвета вершин
	material.albedo_color = Color(1,1,1) # Устанавливаем albedo_color в белый
	terrain_mesh.material_override = material
	add_child(terrain_mesh)
	# Печатаем цвет материала
	#print("Mesh color: ", mesh_instance.material_override.albedo_color)

	# Создание коллизии
	if collision:
		remove_child(collision)
		collision.queue_free()

	collision = StaticBody3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	collision.add_child(shape)
	add_child(collision)

	# Устанавливаем позицию игрока
	if player:
		player.position = spawn_position


func get_color_for_height(height: float) -> Color:
	if height < WATER_LEVEL + 1.0:
		return Color.DARK_RED #(0.15, 0.35, 0.1)  # Болотистый зеленый
	elif height < WATER_LEVEL + 4.0:
		return Color(0.3, 0.6, 0.2)  # Яркая трава
	elif height < MAX_HEIGHT * 0.6:
		return Color(0.45, 0.35, 0.2)  # Земля
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
	
	material.albedo_color = Color(0.05, 0.1, 0.15, 0.7)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	water_mesh.material_override = material
	add_child(water_mesh)



func position_player():
	player.position.y += 5.0  # Поднимаем игрока немного, чтобы избежать залипания

func add_sunlight():
	var light = DirectionalLight3D.new()
	light.light_energy = 1  # Интенсивность света
	light.rotation_degrees = Vector3(-45, 0-45, 0)  # Угол падения света
	light.shadow_enabled = true  # Включить тени
	add_child(light)
	
func get_smoothed_height(x, z):
	var h1 = get_height(x - 1, z) 
	var h2 = get_height(x + 1, z) 
	var h3 = get_height(x, z - 1) 
	var h4 = get_height(x, z + 1)
	return (h1+h2+h3+h4 )/ 4.0  # Усредняем высоту
