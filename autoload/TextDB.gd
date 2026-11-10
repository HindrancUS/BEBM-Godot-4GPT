extends Node

var texts: Dictionary = {}
var file_path := "res://texts.json"

func _ready() -> void:
	load_texts()

func load_texts() -> void:
	if not FileAccess.file_exists(file_path):
		push_error("Файл texts.json не найден!")
		return

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Не удалось открыть texts.json: " + error_string(FileAccess.get_open_error()))
		return
	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("Ошибка чтения JSON: " + json.get_error_message())
		return
	if not json.data is Dictionary:
		push_error("Ошибка чтения JSON: корневой элемент должен быть объектом (словарём).")
		return

	texts = json.data

# Функция для получения текста с автозаменой
func get_text(key: String) -> String:
	var text := str(texts.get(key, "[Текст для '%s' не найден!]" % key))
	text = text.replace("{hunter}", str(GameState.hunter))
	text = text.replace("{target}", str(GameState.target))
	text = text.replace("{hp}", str(GameState.HP_t))
	return text
