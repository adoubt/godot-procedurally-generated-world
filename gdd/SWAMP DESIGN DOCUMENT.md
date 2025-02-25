# **Swamp Design Doc**

## **Концепт**

### **Интро**
"Swamp" — это мрачная survival action-RPG с элементами roguelike. Игрок попадает в болотный мир, где смерть неизбежна, но каждая неудача делает его сильнее. Главное — адаптироваться, изучая яды, грибы и болезни, чтобы превратить слабости в силу. Убийство боссов открывает новые механики, а мир бесконечно перерождается.

### **Фичи**
- Уникальная механика **развития иммунитета** через получение урона.
- **Процедурно генерируемые** болота с опасными биомами.
- **Сетевой элемент** — посещение чужих миров.
- **Боссы с наградами**, изменяющими геймплей.
- **Реиграбельность** через цикличное перерождение мира.

### **Жанр, платформа**
- **Жанр:** Survival, Action-RPG, Roguelike.
- **Платформа:** PC, возможные версии для консолей.

### **Концепт-арт**
#### **пинтрест**
- ТОПИ - https://pin.it/4oEJPKOou
- ЗАЛЕСЬЕ - https://pin.it/14H5dwxkR
- ГНИЛЬНИК - https://pin.it/2yo0JRlXq




## **Геймплей**

### **Кор механики**
- **Иммунитет через урон** — чем больше страдаешь, тем лучше иммунитет("резист", "сопротивление"). Игрок должен получать игрон и дебафы от мобов, грибов, ядов, для повышения иммунитета.
- **Смертоносные грибы** — знания о них приобретаются со временем. Грибы наносят не фиксированный урон, а случайный в диапазоне, а так же зависящий от прогресса и влияния грибницы. с шансом прока временных и постоянных дебафов. 
- **Глоссарий грибов** — Не обязательная но полезная механика ведения глоссария. Игрок может документировать опыты употребления грибов, дебаф от смерти. Взаимодействие с элементами игры, как например убийство босса знахаря будет уточнять или переписывать глоссарий грибов. 

### **Флоу и мотивация**
1. Исследовать болото, находить грибы, пробовать их, искать боссов.
2. Укреплять организм через постепенное отравление, чтобы снизить риск смерти от гриба.
3. Смерить от гриба снижает иммунитет.
4. Фармить мобов, получать урон и лута в виде органических ресурсов для крафта\мутаций.
5. Убивать боссов, получая новые механики.
6. Перерождение мира → начало нового цикла без потери статов и инвентаря. В новом цикле грибы усиливаются и меняют свои параметры.

### **Мобы, боссы, сущности**
- **Мобы**: ПАУКИ, лягушки.
- **Боссы**:
  - Утопленник — даёт телепорт через самоутопление.
  - Знахарь болота — открывает свойства грибов. (его сложно найти)
  - (Другие боссы TBD). 
- **Сущности**:
  - Грибница (Мицелий) — физ. сущность присутствующая в мире. Реагирует на взаимодействие игрока с грибами. Штрафует игрока за срыв грибов мультипликатором к урону грибов, частотой спавна, удалением грибов из цикла. Говорят, что Мицелий это глаза и уши Болота. 
  - Болото — миф. сущность присутствующая в мире. Раньше было множество биомов, но с гибелью мира осталось только оно. Болото строит новые биомы по своему подобию. Болото убивает живое и воскрешает мертвое. Болото не подчиняется законам природы, морали, справедливости и уж тем более не подчинится тебе. 

### **Ресурсы и предметы**
- Грибы (ядовитые, целебные, мутационные).
- Ресурсы для крафта (деревья, минералы, кустарники, ягоды).
- Оружие (палка, нож)
- Инструменты(собиратель ягод, селки для охоты, нож для среза грибов.)
- Экипировка(Одежда и амулеты)
- Редкие ресурсы (получаемые с боссов: мутаген утопленника, глоссарий знахаря).

### **Физика и статы**
- Основные параметры: Здоровье, Иммунитет, Выносливость, Температура тела, Скорость передвижения, Восстановление здоровья в сек., Восстановление выносливости в сек. 
- Бафы, дебафы. 
- Виды урона

### **AI мобов и мира**
- Динамическое поведение мобов (реагируют на температуру тела, звуки, количество лута в инвентаре).
- Мир «живет» — грибные споры разрастаются, погода изменяется, мобы преследуют свои цели.





## **Управление**
- **PC:** клавиатура + мышь / геймпад.
- Плавное передвижение, инвентарь и взаимодействие с объектами.



## **UI**

### **Start Menu**
- "Новая игра"
- "Продолжить"
- "Настройки"
- "Мультиплеер"
- "Выход"

### **In-Game Menu**
- "Продолжить"
- "Сохранить"
- "Загрузить"
- "Пригласить"
- "Настройки"
- "Выход"

### **Статусбар и GUI**
- Полоска здоровья + резист + стамина.
- Визуализация отравлений и эффектов грибов.
- Карта
- Статистика
- Инвентарь

### **Инвентарь, прокачка, глоссарий**
- Описание каждого найденного ресурса.
- Древо мутаций персонажа.
- Глоссарий грибов
- Глоссарий мобов

### **Крафт-панели, сундуки**
- Возможность крафта примитивных инструментов.
- Сундуки для хранения редких предметов.





## **Ассеты**

### **2D и 3D**
- Тёмная стилистика, глубокие оттенки зелени, коричневого, серого.
- Динамическое освещение, эффект гниения и сырости.

### **Саунд и музыка**
- Амбиентные звуки природы (лягушки, капли, ветер).
- Динамическая музыка в зависимости от состояния персонажа.





## **Лор**

### **Локации и биомы**
- **Тёмные топи** — начало пути.
- **Туманные земли** — территория с повышенной сложностью.
- **Грибные леса** — биом с самыми редкими ресурсами.





## **Анализ**

### **Для кого игра?**
- Любители сложных игр с высокой реиграбельностью (Dark Souls, Hollow Knight).
- Фанаты survival и roguelike-механик.

### **Референсы**
#### **Хорошие:**
- **Dark Souls** (мрачная атмосфера, боссы как источники силы).
- **Hollow Knight** (прогресс через исследование, визуальный стиль).
- **Risk of Rain** (цикл прохождения и прогресс).

#### **Плохие:**
- **Игры с автолевелингом** (не дают мотивации становиться сильнее).
- **Survival без глубокой механики прогресса**.




## **Ссылки**
(Placeholder для ссылок на референсы, концепт-арты и другие материалы.)

