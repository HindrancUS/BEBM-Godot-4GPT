extends Control

@onready var list: ItemList = $MainLayout/Body/ItemList
@onready var text_edit: TextEdit = $MainLayout/Body/EditorPanel/TextEdit
@onready var save_btn: Button = $MainLayout/Body/EditorPanel/Toolbar/SaveButton
@onready var search_edit: LineEdit = $MainLayout/Toolbar/SearchEdit
@onready var new_key_edit: LineEdit = $MainLayout/Toolbar/NewKeyEdit
@onready var status_label: Label = $MainLayout/StatusLabel

var current_key: String = ""
var visible_keys: Array[String] = []
var is_dirty: bool = false
var pending_key: String = ""
var saved_snapshot: Dictionary = {}

var switch_dialog: ConfirmationDialog
var delete_dialog: ConfirmationDialog
var close_dialog: ConfirmationDialog

func _ready() -> void:
	TextDB.load_texts()
	saved_snapshot = TextDB.texts.duplicate(true)
	_build_dialogs()
	list.item_selected.connect(_on_item_selected)
	text_edit.text_changed.connect(_on_text_changed)
	save_btn.pressed.connect(_on_save_pressed)
	search_edit.text_changed.connect(_on_search_changed)
	$MainLayout/Toolbar/AddButton.pressed.connect(_on_add_pressed)
	$MainLayout/Body/EditorPanel/Toolbar/DeleteButton.pressed.connect(_on_delete_pressed)
	_refresh_list()
	_set_editor_enabled(false)
	_set_status("Готово. Выбери текст слева.")

func _build_dialogs() -> void:
	switch_dialog = ConfirmationDialog.new()
	switch_dialog.title = "Несохранённые изменения"
	switch_dialog.dialog_text = "Сохранить изменения перед переключением?"
	switch_dialog.ok_button_text = "Сохранить и продолжить"
	switch_dialog.add_button("Не сохранять", true, "discard")
	switch_dialog.confirmed.connect(_on_switch_save)
	switch_dialog.custom_action.connect(_on_switch_discard)
	switch_dialog.canceled.connect(_on_switch_cancel)
	add_child(switch_dialog)

	delete_dialog = ConfirmationDialog.new()
	delete_dialog.title = "Удалить текст?"
	delete_dialog.dialog_text = "Ключ и его текст будут удалены после сохранения файла."
	delete_dialog.confirmed.connect(_on_delete_confirmed)
	add_child(delete_dialog)

	close_dialog = ConfirmationDialog.new()
	close_dialog.title = "Несохранённые изменения"
	close_dialog.dialog_text = "Перед закрытием сохранить изменения?"
	close_dialog.ok_button_text = "Сохранить и выйти"
	close_dialog.add_button("Выйти без сохранения", true, "discard")
	close_dialog.confirmed.connect(_on_close_save)
	close_dialog.custom_action.connect(_on_close_discard)
	add_child(close_dialog)

func _refresh_list(select_key: String = "") -> void:
	list.clear()
	visible_keys.clear()
	var filter: String = search_edit.text.strip_edges().to_lower()
	var keys: Array = TextDB.texts.keys()
	keys.sort()
	for key_variant in keys:
		var key: String = str(key_variant)
		if filter == "" or key.to_lower().contains(filter):
			visible_keys.append(key)
			list.add_item(key)
	if select_key != "":
		var index: int = visible_keys.find(select_key)
		if index >= 0:
			list.select(index)
			_load_key(select_key)

func _on_search_changed(_value: String) -> void:
	if is_dirty:
		_refresh_list()
		_restore_current_selection()
	else:
		_refresh_list(current_key if TextDB.texts.has(current_key) else "")

func _on_item_selected(index: int) -> void:
	if index < 0 or index >= visible_keys.size():
		return
	var selected_key: String = visible_keys[index]
	if selected_key == current_key:
		return
	if is_dirty:
		pending_key = selected_key
		switch_dialog.popup_centered()
		return
	_load_key(selected_key)

func _load_key(key: String) -> void:
	current_key = key
	text_edit.text = str(TextDB.texts.get(key, ""))
	_set_editor_enabled(true)
	_update_status()

func _on_text_changed() -> void:
	if current_key == "":
		return
	is_dirty = text_edit.text != str(TextDB.texts.get(current_key, ""))
	_update_status()

func _on_save_pressed() -> void:
	_save_current()

func _save_current() -> bool:
	if current_key != "":
		TextDB.texts[current_key] = text_edit.text
	var file: FileAccess = FileAccess.open(TextDB.file_path, FileAccess.WRITE)
	if file == null:
		_set_status("ОШИБКА сохранения: " + error_string(FileAccess.get_open_error()), true)
		return false
	var json_string: String = JSON.stringify(TextDB.texts, "\t")
	file.store_string(json_string)
	file.close()
	if file.get_error() != OK:
		_set_status("Ошибка записи файла.", true)
		return false
	is_dirty = false
	saved_snapshot = TextDB.texts.duplicate(true)
	_set_status("Все изменения сохранены.")
	return true

func _on_switch_save() -> void:
	if _save_current():
		_continue_switch()

func _on_switch_discard(action: StringName) -> void:
	if action == "discard":
		TextDB.texts = saved_snapshot.duplicate(true)
		is_dirty = false
		_continue_switch()

func _on_switch_cancel() -> void:
	pending_key = ""
	_restore_current_selection()

func _continue_switch() -> void:
	var next_key: String = pending_key
	pending_key = ""
	if next_key != "":
		_load_key(next_key)
		_restore_current_selection()

func _restore_current_selection() -> void:
	var index: int = visible_keys.find(current_key)
	list.deselect_all()
	if index >= 0:
		list.select(index)

func _on_add_pressed() -> void:
	var key: String = new_key_edit.text.strip_edges()
	if key == "":
		_set_status("Сначала введи имя нового ключа.", true)
		return
	if TextDB.texts.has(key):
		_set_status("Такой ключ уже существует.", true)
		return
	if is_dirty and not _save_current():
		return
	TextDB.texts[key] = ""
	is_dirty = true
	new_key_edit.clear()
	_refresh_list(key)
	_update_status()

func _on_delete_pressed() -> void:
	if current_key == "":
		return
	if is_dirty:
		_set_status("Сначала сохрани изменения.", true)
		return
	delete_dialog.dialog_text = "Удалить ключ «%s»? Изменение вступит в силу после сохранения." % current_key
	delete_dialog.popup_centered()

func _on_close_save() -> void:
	if _save_current():
		get_tree().quit()

func _on_close_discard(action: StringName) -> void:
	if action == "discard":
		get_tree().quit()

func _on_delete_confirmed() -> void:
	if current_key == "":
		return
	var deleted_key: String = current_key
	TextDB.texts.erase(deleted_key)
	is_dirty = true
	current_key = ""
	text_edit.clear()
	_set_editor_enabled(false)
	_refresh_list()
	_set_status("Ключ «%s» удалён. Нажми «Сохранить», чтобы записать изменения в файл." % deleted_key)

func _set_editor_enabled(enabled: bool) -> void:
	text_edit.editable = enabled
	save_btn.disabled = false
	$MainLayout/Body/EditorPanel/Toolbar/DeleteButton.disabled = not enabled

func _set_status(message: String, is_error: bool = false) -> void:
	status_label.text = message
	status_label.modulate = Color(1.0, 0.45, 0.4) if is_error else Color(0.75, 0.85, 0.75)

func _update_status() -> void:
	if is_dirty:
		_set_status("Есть несохранённые изменения • " + current_key)
	else:
		_set_status("Открыт: " + current_key)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_dirty:
			close_dialog.popup_centered()
		else:
			get_tree().quit()
