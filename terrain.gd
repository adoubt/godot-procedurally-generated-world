extends Node3D

@export var terrain_size = float(1000)
@export var water_level = 5.0

func _ready():
	
	setup_camera()
	generate_terrain()
	setup_light()

func setup_camera():
	var camera = get_node("%Camera3D")
	camera.position = Vector3(terrain_size / 2, 50, terrain_size / 2 + 50)  # Камера сверху и сбоку
	add_child(camera)  # Сначала добавляем в сцену
	await get_tree().process_frame  # Ждём один кадр, чтобы узел добавился в дерево
	camera.look_at(Vector3(terrain_size / 2, 0, terrain_size / 2))  # Теперь можно использовать look_at()


func setup_light():
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60, 45, 0)  # Наклонный свет
	add_child(light)

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Храним все вершины в массиве для корректного соединения
	var vertices = []
	var colors = []
	
	for x in range(terrain_size):
		vertices.append([])  # Создаём строку массива
		colors.append([])  # Создаём массив цветов

		for z in range(terrain_size):
			var base_height = get_height(x, z)
			var biome_type = get_biome(x, z)

			# Устанавливаем цвет для визуализации биомов
			var color = Color(1, 1, 1)  # По умолчанию белый
			if base_height <= water_level:
				color = Color(0, 0, 1)  # Синяя вода
			elif biome_type == "ТОПИ":
				color = Color(0.2, 0.4, 0.1)  # Зеленый болот
			elif biome_type == "ЗАЛЕСЬЕ":
				color = Color(0.4, 0.3, 0.2)  # Коричневый лес
			elif biome_type == "ГНИЛЬНИК":
				color = Color(0.3, 0.1, 0.1)  # Темно-красный гнильник

			# Сохраняем вершину и цвет
			vertices[x].append(Vector3(x, base_height, z))
			colors[x].append(color)

	# Создание треугольников
	for x in range(terrain_size - 1):
		for z in range(terrain_size - 1):
			var v1 = vertices[x][z]
			var v2 = vertices[x + 1][z]
			var v3 = vertices[x][z + 1]
			var v4 = vertices[x + 1][z + 1]

			var c1 = colors[x][z]
			var c2 = colors[x + 1][z]
			var c3 = colors[x][z + 1]
			var c4 = colors[x + 1][z + 1]

			# Первый треугольник (v1, v2, v3)
			st.set_color(c1)
			st.add_vertex(v1)
			st.set_color(c2)
			st.add_vertex(v2)
			st.set_color(c3)
			st.add_vertex(v3)

			# Второй треугольник (v2, v3, v4)
			st.set_color(c2)
			st.add_vertex(v2)
			st.set_color(c3)
			st.add_vertex(v3)
			st.set_color(c4)
			st.add_vertex(v4)

	# Создание меша
	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.visible = true
	# Добавляем материал, чтобы объект отрисовывался
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.8, 0.8)  # Светло-серый, можно поменять
	mesh_instance.set_surface_override_material(0, material)
	add_child(mesh_instance)

func get_height(x, z):
	var center = float(terrain_size) / 2
	var dist_to_center = sqrt(pow(x - center, 2) + pow(z - center, 2))
	var base_height = randf_range(2.0, 6.0)

	if dist_to_center < 10:  # В центре делаем гору для ГНИЛЬНИКА
		base_height += (10 - dist_to_center) * 0.5
	return base_height

func get_biome(x, z):
	var center = float(terrain_size) / 2
	var dist_to_center = sqrt(pow(x - center, 2) + pow(z - center, 2))
	
	if dist_to_center < terrain_size * 0.2:
		return "ТОПИ"
	elif dist_to_center < terrain_size * 0.6: 
		return "ЗАЛЕСЬЕ"
	else: 
		return "ГНИЛЬНИК"
