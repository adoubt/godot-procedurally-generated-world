extends Node3D

@export var terrain_size = 200
@export var water_level = 5.0

func _ready():
	setup_camera()
	generate_terrain()
	setup_light()

func setup_camera():
	var camera = get_node("%Camera3D")
	camera.position = Vector3(terrain_size / 2, 50, terrain_size / 2 + 50)  # Камера сверху и сбоку
	camera.look_at(Vector3(terrain_size / 2, 0, terrain_size / 2))  # Теперь можно использовать look_at()

func setup_light():
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60, 45, 0)  # Наклонный свет
	add_child(light)

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var prev_biome = null 
	var vertices = []

	for x in range(terrain_size):
		for z in range(terrain_size):
			var base_height = get_height(x, z)
			var biome_type = get_biome(x, z)

			if biome_type != prev_biome:
				print("x:", x, " z:", z, " biome изменился на: ", biome_type)  
				prev_biome = biome_type  

			# Определяем цвет биома
			var color = Color(1, 1, 1)  # Белый по умолчанию
			if base_height <= water_level:
				color = Color(0, 0, 1)  # Синяя вода
			elif biome_type == "ТОПИ":
				color = Color(0.2, 0.4, 0.1)  # Зеленый болот
			elif biome_type == "ЗАЛЕСЬЕ":
				color = Color(0.4, 0.3, 0.2)  # Коричневый лес
			elif biome_type == "ГНИЛЬНИК":
				color = Color(0.3, 0.1, 0.1)  # Темно-красный гнильник
			
			st.set_color(color)
			st.add_vertex(Vector3(x, base_height, z))
			vertices.append(Vector3(x, base_height, z))
	
	# Применяем индексы для треугольников (заметьте, что соединение вершин нужно для правильных треугольников)
	for i in range(terrain_size - 1):
		for j in range(terrain_size - 1):
			var idx1 = i * terrain_size + j
			var idx2 = idx1 + 1
			var idx3 = (i + 1) * terrain_size + j
			var idx4 = idx3 + 1
			
			# Первый треугольник
			st.add_index(idx1)
			st.add_index(idx2)
			st.add_index(idx3)
			
			# Второй треугольник
			st.add_index(idx3)
			st.add_index(idx2)
			st.add_index(idx4)

	# Создаём и применяем материал
	var material = ShaderMaterial.new()
	material.shader = preload("res://terrain_shader.tres")  # Создадим шейдер ниже
	
	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material  # Применяем материал!
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
