extends Node

# ---- Настройки (из START) ----
var setting_cpu_h := false
var setting_cpu_t := false
var setting_logs := false
var setting_hunter_text := true
var setting_target_text := true
var setting_default_text := false

# ---- Выбор персонажей ----
var hunter := ""
var target := ""

# ---- Статы охотника ----
var mHP_h := 0
var HP_h := 0
var STR_h := 0
var DEX_h := 0
var SPD_h := 0
var MAG_h := 0

# ---- Статы цели ----
var mHP_t := 0
var HP_t := 0
var STR_t := 0
var DEX_t := 0
var SPD_t := 0
var MAG_t := 0

# ---- Массивы ----
var traits_h: Array = []
var abils_h: Array = []
var AI_h: Array = []
var traits_t: Array = []
var abils_t: Array = []
var AI_t: Array = []
var effects: Array = []

# ---- Бинды (могут быть int 0 или String, поэтому без :=) ----
var binds_gag_1 = 0
var binds_hands_1 = 0
var binds_legs_1 = 0
var binds_gag_2 = 0
var binds_hands_2 = 0
var binds_legs_2 = 0

var gag = 0
var hands = 0
var legs = 0

# ---- Состояние сцены ----
var phase := ""
var stance := ""
var turn := ""
var scene := ""

# ---- Счётчики ----
var counter_run := 0
var counter_beaten := 0
var counter_helpless := 0
var counter_guard := 0

# ---- Выбор (может быть null, String, Array) ----
var choice: Array = []
var choice_h = null
var choice_t = null

# ---- Текст ----
var current_text: Array = []
var text_log: Array = []

# ---- Инициализация (порт INITIAL) ----
func initial_setup() -> void:
	hunter = ""
	target = ""
	mHP_h = 0; HP_h = 0; STR_h = 0; DEX_h = 0; SPD_h = 0; MAG_h = 0
	mHP_t = 0; HP_t = 0; STR_t = 0; DEX_t = 0; SPD_t = 0; MAG_t = 0
	traits_h = []; abils_h = []; AI_h = []
	traits_t = []; abils_t = []; AI_t = []
	effects = []
	binds_gag_1 = 0; binds_hands_1 = 0; binds_legs_1 = 0
	binds_gag_2 = 0; binds_hands_2 = 0; binds_legs_2 = 0
	gag = 0; hands = 0; legs = 0
	phase = ""; stance = ""; turn = ""
	scene = ""
	counter_run = 0; counter_beaten = 0
	counter_helpless = 0; counter_guard = 0
	choice = []; choice_h = null; choice_t = null
	current_text = []; text_log = []
	setting_cpu_h = false
	setting_cpu_t = false
	setting_logs = false

# ---- Применить данные персонажа ----
func apply_hunter(name: String) -> void:
	var d: Dictionary = CharacterDB.HUNTERS.get(name, {})
	if d.is_empty():
		push_error("Unknown hunter: " + name)
		return
	mHP_h = d.mhp
	HP_h = d.mhp
	STR_h = d.str
	DEX_h = d.dex
	SPD_h = d.spd
	MAG_h = d.mag
	traits_h = d.traits.duplicate()
	abils_h = d.abils.duplicate()
	AI_h = d.ai.duplicate()
	binds_gag_1 = d.binds.gag
	binds_hands_1 = d.binds.hands
	binds_legs_1 = d.binds.legs

func apply_target(name: String) -> void:
	var d: Dictionary = CharacterDB.TARGETS.get(name, {})
	if d.is_empty():
		push_error("Unknown target: " + name)
		return
	mHP_t = d.mhp
	HP_t = d.mhp
	STR_t = d.str
	DEX_t = d.dex
	SPD_t = d.spd
	MAG_t = d.mag
	traits_t = d.traits.duplicate()
	abils_t = d.abils.duplicate()
	AI_t = d.ai.duplicate()
	binds_gag_2 = d.binds.gag
	binds_hands_2 = d.binds.hands
	binds_legs_2 = d.binds.legs
