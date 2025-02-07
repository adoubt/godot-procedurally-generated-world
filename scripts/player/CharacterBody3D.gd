extends CharacterBody3D

# Базовые параметры передвижения
@export var mouse_sensitivity: float = 0.2  # Чувствительность мыши
@export var base_speed: float = 7.0  # Базовая скорость передвижения
@export var stealth_speed: float = 2.0  # Скорость в режиме скрытности
@export var sprint_speed: float = 15.0  # Скорость при беге
@export var jump_velocity: float = 20.0  # Высота прыжка
@export var base_gravity: float = 1.4 * ProjectSettings.get_setting("physics/3d/default_gravity")  # Гравитация
@export var acceleration: float = 100.0  # Насколько быстро ускоряется персонаж
@export var deceleration: float = 100.0  # Насколько быстро замедляется персонаж
@export var blink_distance: float =1.0  # Расстояние рывка
@export var blink_duration: float = 0.3  # Длительность рывка

var blink_timer: float = -1.0  # Таймер для рывка, начинается с -1, чтобы рывок не был активирован сразу
var current_gravity: float
var current_speed: float  # Текущая скорость передвижения
var is_sprinting: bool = false
var is_stealth: bool = false
var character_mesh: Node  # Переменная для хранения объекта с мешем
var camera_pivot  # Узел CameraPivot
var camera  # Узел Camera3D
var rotation_x = 0.0  # Угол наклона камеры вверх-вниз

func _ready():
	# Создаем персонажа с мешем
	character_mesh = preload("res://scripts/player/CharacterMesh.gd").new()
	add_child(character_mesh)  # Добавляем персонажа в сцену

	current_speed = base_speed  # по олчанию стандартная скорость
	current_gravity = base_gravity  # Изначально гравитация стандартная
	camera_pivot = $CameraPivot  # Получаем узел CameraPivot
	camera = $CameraPivot/Camera3D  # Получаем узел Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Скрываем и блокируем курсор

func _input(event):
	# Управление мышью
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -75, 75)  # Ограничиваем наклон камеры
		camera_pivot.rotation_degrees.x = rotation_x

		rotation_degrees.y -= event.relative.x * mouse_sensitivity  # Поворот персонажа
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)		
	# Включаем блинк при нажатии клавиши
	if Input.is_action_just_pressed("1item") and blink_timer < 0.0:
		perform_blink()

func _physics_process(delta):
	
	_apply_gravity(delta)
	_handle_movement(delta)
	move_and_slide()

func _apply_gravity(delta):
	# Применяем гравитацию, если не стоим на земле
	if not is_on_floor():
		velocity.y -= current_gravity * delta

func _handle_movement(delta):
	# Получаем входные данные (направление движения)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Проверяем нажатие кнопок и изменяем скорость
	if Input.is_action_pressed("sprint") and is_on_floor():  # Ctrl - ускорение
		is_sprinting = true
		is_stealth = false
	elif Input.is_action_pressed("stealth") and is_on_floor():  # Shift - скрытность
		is_stealth = true
		is_sprinting = false
	else:
		is_sprinting = false
		is_stealth = false

	# Устанавливаем скорость в зависимости от режима
	if is_sprinting:
		current_speed = sprint_speed
	elif is_stealth:
		current_speed = stealth_speed
	else:
		current_speed = base_speed

	# Применяем ускорение / замедление для плавного движения
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)
	
	# Прыжок на пробел
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

# Функция для быстрого блинка
func perform_blink():
	# Устанавливаем начальное время рывка
	blink_timer = 0.0
func set_gravity(new_gravity: float):
	current_gravity = new_gravity  # Меняем гравитацию в зависимости от обуви или других факторов


# Вставляем логику рывка в _process или _physics_process
func _process(delta):
	if blink_timer >= 0.0:
		blink_timer += delta
		if blink_timer < blink_duration:
			# Линейная интерполяция (плавное движение)
			var blink_direction = -camera.global_transform.basis.z.normalized()
			var target_position = global_position + blink_direction * blink_distance
			global_position = global_position.lerp(target_position, blink_timer / blink_duration)
		else:
			# После окончания рывка
			blink_timer = -1.0

func on_item_equipped(item):
	if item.name == "heavy_boots":
		set_gravity(12.0)  # Увеличиваем гравитацию для тяжелой обуви
	elif item.name == "light_boots":
		set_gravity(6.0)  # Уменьшаем гравитацию для легкой обуви 


	# Дополнительно можно добавить эффект блинка, например, с анимацией или эффектами
