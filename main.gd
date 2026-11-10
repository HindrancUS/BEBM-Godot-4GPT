extends Control

@onready var output: RichTextLabel = $VBox/Scroll/Output
@onready var choices_box: VBoxContainer = $VBox/Choices

func _ready() -> void:
	GameState.initial_setup()
	TextDB.load_texts() # Загружаем тексты из JSON при старте игры
	goto("START")

# ---- Диспетчер пассажей ----
func goto(passage: String) -> void:
	output.clear()
	for c in choices_box.get_children():
		c.queue_free()
	GameState.current_text = []

	match passage:
		"START":              _p_START()
		"Select Hunter":      _p_SelectHunter()
		"Select Target":      _p_SelectTarget()
		"Begin Story":        _p_BeginStory()
		"approach openly":    _p_ApproachOpenly()
		"approach sneakily":  _p_ApproachSneakily()
		"show yourself":      _p_ShowYourself()
		"statuscontrol":      _p_StatusControl()
		"HUB":                _p_Hub()
		"END":                _p_End()
		_:
			output.add_text("[Unknown passage: %s]\n" % passage)

# ---- Хелперы ----
func say(text: String) -> void:
	print("ВЫВОД ТЕКСТА: ", text) # <--- Вот сюда!
	GameState.current_text.append(text)
	output.add_text(text + "\n")

# НОВАЯ ФУНКЦИЯ: берет текст по ключу из JSON
func say_key(key: String) -> void:
	say(TextDB.get_text(key))

func add_choice(label: String, passage: String) -> void:
	var b := Button.new()
	b.text = label
	b.pressed.connect(goto.bind(passage))
	choices_box.add_child(b)

func add_choice_action(label: String, action: Callable) -> void:
	var b := Button.new()
	b.text = label
	b.pressed.connect(action)
	choices_box.add_child(b)

# ---- Пассажи ----

func _p_START() -> void:
	say("BM+BAvs")
	say("HindrancUS")
	say("")
	add_choice_action(
		"HUNTER's CPU: " + ("ON" if GameState.setting_cpu_h else "OFF"),
		func():
			GameState.setting_cpu_h = not GameState.setting_cpu_h
			goto("START")
	)
	add_choice_action(
		"TARGET's CPU: " + ("ON" if GameState.setting_cpu_t else "OFF"),
		func():
			GameState.setting_cpu_t = not GameState.setting_cpu_t
			goto("START")
	)
	add_choice("START", "Select Hunter")

func _p_SelectHunter() -> void:
	say("SELECT HUNTER")
	say("")
	for name in ["Barbarian", "Thief", "Wizard"]:
		add_choice_action(name, _choose_hunter.bind(name))
	add_choice_action("Random Hunter", _choose_random_hunter)

func _choose_hunter(name: String) -> void:
	GameState.hunter = name
	goto("Select Target")

func _choose_random_hunter() -> void:
	var pool = ["Barbarian", "Thief", "Wizard"]
	GameState.hunter = pool[randi() % pool.size()]
	goto("Select Target")

func _p_SelectTarget() -> void:
	say("SELECT TARGET")
	say("")
	for name in ["Amazon", "Sorceress", "Maid"]:
		add_choice_action(name, _choose_target.bind(name))
	add_choice_action("Random Target", _choose_random_target)

func _choose_target(name: String) -> void:
	GameState.target = name
	goto("Begin Story")

func _choose_random_target() -> void:
	var pool = ["Amazon", "Sorceress", "Maid"]
	GameState.target = pool[randi() % pool.size()]
	goto("Begin Story")

func _p_BeginStory() -> void:
	GameState.apply_hunter(GameState.hunter)
	GameState.apply_target(GameState.target)

	GameState.gag = 0
	GameState.hands = 0
	GameState.legs = 0
	GameState.effects = []
	GameState.phase = "stealth"
	GameState.stance = "range"
	GameState.scene = "start"
	GameState.turn = ""

	# БЫЛО say("%s knew the %s...") - СТАЛО:
	say_key("begin_story")
	say("")

	var choices := ["approach openly", "approach sneakily"]
	GameState.choice = choices

	if GameState.setting_cpu_h:
		var pick: String = choices[randi() % choices.size()]
		GameState.choice_h = pick
		say("(CPU picks: %s)" % pick)
		goto(pick)
	else:
		for c in choices:
			add_choice(c.capitalize(), c)

func _p_ApproachOpenly() -> void:
	var dice := randi_range(1, 6)
	if GameState.SPD_h < dice:
		GameState.scene = "approach openly slow"
		GameState.turn = "t"
		GameState.phase = "spotted"
		GameState.stance = "range"
		say_key("approach_openly_slow") # <--- Взято из JSON
	else:
		GameState.scene = "approach openly fast"
		GameState.turn = "h"
		GameState.phase = "spotted"
		GameState.stance = "range"
		say_key("approach_openly_fast") # <--- Взято из JSON
	goto("statuscontrol")

func _p_ApproachSneakily() -> void:
	GameState.scene = "approach sneakily"

	if "magicalwards" in GameState.traits_t:
		var dice := randi_range(1, 6)
		if dice <= GameState.MAG_h:
			GameState.phase = "stealth"
			GameState.stance = "range"
			GameState.turn = "h"
			say_key("approach_sneak_mag_win") # <--- Взято из JSON
		else:
			GameState.phase = "spotted"
			GameState.stance = "range"
			GameState.turn = "t"
			say_key("approach_sneak_mag_fail") # <--- Взято из JSON
	else:
		var dice := randi_range(1, 6)
		if GameState.DEX_h < dice:
			GameState.phase = "spotted"
			GameState.stance = "range"
			GameState.turn = "t"
			say_key("approach_sneak_fail") # <--- Взято из JSON
		else:
			GameState.phase = "stealth"
			GameState.stance = "range"
			GameState.turn = "h"
			say_key("approach_sneak_win") # <--- Взято из JSON
	goto("statuscontrol")

func _p_ShowYourself() -> void:
	GameState.scene = "stealth appear"
	GameState.phase = "spotted"
	GameState.stance = "range"
	GameState.turn = "h"
	say_key("stealth_appear") # <--- Взято из JSON
	goto("statuscontrol")

func _p_StatusControl() -> void:
	goto("HUB")

func _p_Hub() -> void:
	say("[phase=%s stance=%s turn=%s]" % [GameState.phase, GameState.stance, GameState.turn])
	say("")

	if GameState.turn == "r":
		var dice := randi_range(1, 6)
		GameState.turn = "h" if dice > 3 else "t"
		goto("HUB")
		return

	if GameState.turn == "h":
		_show_h_choices()
	elif GameState.turn == "t":
		_show_t_choices()
	else:
		say("[no turn set — end of demo]")
		add_choice("(End demo)", "END")

func _show_h_choices() -> void:
	say("-- HUNTER's choice --")
	if GameState.phase == "stealth" and GameState.stance == "range":
		add_choice("Show yourself.", "show yourself")
		add_choice("(End demo)", "END")
	elif GameState.phase == "spotted":
		say("[demo: hello / demand surrender / attack — not implemented yet]")
		add_choice("(End demo)", "END")
	else:
		say("[phase %s not implemented yet]" % GameState.phase)
		add_choice("(End demo)", "END")

func _show_t_choices() -> void:
	say("-- TARGET's choice --")
	if GameState.phase == "spotted":
		say("[demo: talk / prepare / flee — not implemented yet]")
		add_choice("(End demo)", "END")
	else:
		say("[phase %s not implemented yet]" % GameState.phase)
		add_choice("(End demo)", "END")

func _p_End() -> void:
	say("END")
	say("")
	say("Демо-скелет работает. Дальше по этой же схеме.")
	add_choice("Начать заново", "Begin Story")
