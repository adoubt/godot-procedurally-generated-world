extends Node

# Константы для генерации мира
const GENERATION_BOUND_DISTANCE = 64  # Радиус генерации кубов вокруг игрока
const VERTICAL_AMPLITUDE = 100  # Максимальная высота колебаний кубов (влияет на рельеф)


var noise = FastNoiseLite.new()  # Генератор шума для высоты ландшафта
var player: Node  # Ссылка на игрока
var generated_cubes  # Словарь для хранения сгенерированных кубов




func _ready():
	generated_cubes = {}  # Инициализация словаря сгенерированных кубов
	player = get_node("../Player")  # Получаем ссылку на объект игрока
	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN  # Используем перлин-шум
	noise.frequency = 0.005  # Делает рельеф более масштабным
	noise.fractal_octaves = 5  # Добавляем больше деталей
	noise.fractal_lacunarity = 2.0  # Контрастность больших и мелких форм
	noise.fractal_gain = 0.5  # Влияние каждой следующей октавы

	generate_new_cubes_from_position(player.position)  # Генерируем кубы в начальной позиции игрока

# Функция генерации новых кубов вокруг позиции игрока
func generate_new_cubes_from_position(player_position):
	for x in range(GENERATION_BOUND_DISTANCE * 2):
		x += (player_position.x - GENERATION_BOUND_DISTANCE)  # Коррекция координаты x относительно центра
		for z in range(GENERATION_BOUND_DISTANCE * 2):
			z += (player_position.z - GENERATION_BOUND_DISTANCE)  # Коррекция координаты z относительно центра
			generate_cube_if_new(x, z)  # Генерация куба, если он еще не создан

# Проверка, был ли куб уже создан, и его генерация, если нет
func generate_cube_if_new(x, z):
	if !has_cube_been_generated(x, z):  # Проверяем, есть ли уже куб на этих координатах
		var generated_noise = noise.get_noise_2d(x, z)  # Получаем значение шума для изменения высоты
		create_cube(Vector3(x, generated_noise * VERTICAL_AMPLITUDE, z), get_color_from_noise(generated_noise))
		register_cube_generation_at_coordinate(x, z)  # Запоминаем, что на этих координатах есть куб

# Проверяет, был ли уже создан куб в данной координате
func has_cube_been_generated(x, z):
	return x in generated_cubes and z in generated_cubes[x] and generated_cubes[x][z] == true

# Регистрирует координаты нового куба в словаре
func register_cube_generation_at_coordinate(x, z):
	if x in generated_cubes:
		generated_cubes[x][z] = true
	else:
		generated_cubes[x] = {z: true}

# Обновление мира каждую обработку кадра
func _process(delta):
	generate_new_cubes_from_position(player.position)  # Генерируем новые кубы в зависимости от позиции игрока

# Функция создания куба в мире
func create_cube(position, color):
	var box_size = Vector3(1, 1, 1)  # Размер куба

	var static_body = StaticBody3D.new()  # Создаем статический объект (куб)
	static_body.position = position

	var collision_shape_3d = CollisionShape3D.new()  # Создаем коллизию для куба
	collision_shape_3d.shape = BoxShape3D.new()
	collision_shape_3d.shape.size = box_size

	var mesh = MeshInstance3D.new()  # Создаем меш для отображения куба
	var boxmesh = BoxMesh.new()
	boxmesh.size = box_size

	var material = StandardMaterial3D.new()  # Создаем материал для куба
	material.albedo_color = color  # Устанавливаем цвет куба
	boxmesh.material = material

	mesh.set_mesh(boxmesh)  # Применяем меш к объекту
	static_body.add_child(mesh)  # Добавляем меш как дочерний объект
	static_body.add_child(collision_shape_3d)  # Добавляем коллизию
	
	add_child(static_body)  # Добавляем объект в сцену

# Функция для выбора цвета куба в зависимости от шума
func get_color_from_noise(noise_value):
	if noise_value <= -0.4:
		return Color(1, 0, 0, 1)  # Красный
	elif noise_value <= -0.2:
		return Color(0, 1, 0, 1)  # Зеленый
	elif noise_value <= 0:
		return Color(0, 0, 1, 1)  # Синий
	elif noise_value <= 0.2:
		return Color(0.5, 0.5, 0.5, 1)  # Серый
	else:
		return Color(0.3, 0.8, 0.5, 1)  # Бирюзовый
