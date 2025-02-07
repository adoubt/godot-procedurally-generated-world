extends Node3D

var mesh_instance: MeshInstance3D
var immediate_mesh: ImmediateMesh

func _ready():
	# Создаем экземпляр MeshInstance3D и ImmediateMesh
	mesh_instance = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()

	# Присваиваем созданный меш к экземпляру MeshInstance
	mesh_instance.mesh = immediate_mesh

	# Начинаем создание меша
	immediate_mesh.clear_surfaces()  # Очищаем предыдущие поверхности, если они были
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)  # Определяем тип примитивов

	# Генерируем тело (пример лоу-поли персонажа)
	create_detailed_low_poly_character()

	immediate_mesh.surface_end()  # Закрываем создание поверхности

	# Добавляем MeshInstance в сцену
	add_child(mesh_instance)

# Функция для создания более реалистичного лоу-поли персонажа
func create_detailed_low_poly_character():
	# 1. Голова (Сфера с большим числом полигонов)
	var head_size = 1.0
	var head_position = Vector3(0, 2.5, 0)
	create_sphere(head_position, head_size)

	# 2. Туловище (Цилиндр с большим числом сегментов)
	var body_size = Vector3(1, 2, 0.6)
	var body_position = Vector3(0, 0.5, 0)
	create_cylinder(body_position, body_size.x, body_size.y, 8)  # 8 сегментов

	# 3. Руки (Цилиндры с плавными переходами)
	var arm_size = Vector3(0.3, 1.2, 0.3)
	var arm_position_left = Vector3(-1.2, 1.2, 0)
	var arm_position_right = Vector3(1.2, 1.2, 0)
	create_cylinder(arm_position_left, arm_size.x, arm_size.y, 6)  # 6 сегментов
	create_cylinder(arm_position_right, arm_size.x, arm_size.y, 6)  # 6 сегментов

	# 4. Ноги (Цилиндры)
	var leg_size = Vector3(0.4, 1.5, 0.4)
	var leg_position_left = Vector3(-0.6, -1, 0)
	var leg_position_right = Vector3(0.6, -1, 0)
	create_cylinder(leg_position_left, leg_size.x, leg_size.y, 8)  # 8 сегментов
	create_cylinder(leg_position_right, leg_size.x, leg_size.y, 8)  # 8 сегментов

# Функция для создания сферы
func create_sphere(position: Vector3, radius: float):
	var segments = 8
	var stack_count = 8
	for i in range(segments):
		for j in range(stack_count):
			var theta = float(i) / float(segments) * PI * 2
			var phi = float(j) / float(stack_count) * PI
			var x = radius * sin(phi) * cos(theta)
			var y = radius * sin(phi) * sin(theta)
			var z = radius * cos(phi)
			var vertex = Vector3(x, y, z)
			immediate_mesh.surface_add_vertex(position + vertex)
	
	# Составление треугольниковw
	var triangle_count = segments * stack_count * 2  # Каждая пара вершин (в верхней и нижней части) даёт 2 треугольника
	var vertices = []
	
	# Добавление вершин в треугольники
	for i in range(0, len(vertices), 3):
		immediate_mesh.surface_add_vertex(vertices[i])   # Первая вершина
		immediate_mesh.surface_add_vertex(vertices[i + 1])  # Вторая вершина
		immediate_mesh.surface_add_vertex(vertices[i + 2])  # Третья вершина

# Функция для создания цилиндра
func create_cylinder(position: Vector3, radius: float, height: float, segments: int):
	var angle_step = 2 * PI / segments
	var top_vertices = []
	var bottom_vertices = []

	# Создаём вершины для верхней и нижней части цилиндра
	for i in range(segments):
		var angle = i * angle_step
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		
		var bottom_vertex = Vector3(x, -height / 2, z) + position
		var top_vertex = Vector3(x, height / 2, z) + position
		
		bottom_vertices.append(bottom_vertex)
		top_vertices.append(top_vertex)

	# Составление треугольников
	for i in range(segments):
		var next_i = (i + 1) % segments
		immediate_mesh.surface_add_vertex(bottom_vertices[i])
		immediate_mesh.surface_add_vertex(bottom_vertices[next_i])
		immediate_mesh.surface_add_vertex(top_vertices[i])
		
		immediate_mesh.surface_add_vertex(bottom_vertices[next_i])
		immediate_mesh.surface_add_vertex(top_vertices[next_i])
		immediate_mesh.surface_add_vertex(top_vertices[i])
