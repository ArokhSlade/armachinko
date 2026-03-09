extends MenuTab

signal username_confirmed

var username : String = ""
var regex

func _ready() -> void:
	regex = RegEx.create_from_string("^[A-Z0-9_-]+[A-Z0-9_-]*$")
	remove_special_characters("a!b")
	super()

func activate():
	super()
	$NameEntry.grab_focus.call_deferred()
	

func close() -> void:	
	username = ""
	$NameEntry.text = ""
	super()


func _on_confirm_button_pressed() -> void:
	username = $NameEntry.text
	
	if is_username_valid(): 
		clear_trailing_spaces()
		animation_player.play_backwards("enter_name_tab")		
		PlayerData.update_player(username)
		PlayerData.save_player()
		$NameEnterSound.play()
		await($NameEnterSound.finished)
		username_confirmed.emit()
		print("Username: ", PlayerData.data.name)
	else:
		print("enter your username!")
		$ButtonRejectSound.play()

func is_username_valid():
	return username != ""

func clear_trailing_spaces():
	var name_length = username.length()
	var trailing_spaces_count = 0
	for idx in name_length:
		if username[name_length-1-idx] == ' ':
			trailing_spaces_count += 1
		else:
			break
	if trailing_spaces_count > 0 :
		username = username.left(-trailing_spaces_count)


func _on_name_entry_text_changed(new_text: String) -> void:
	remove_special_characters(new_text)
	#print("new text: ", new_text)
	#print("text: ", $NameEntry.text)
	if not regex.search(new_text):
		$NameEntry.text = remove_special_characters(new_text)
		$NameEntry.caret_column = $NameEntry.text.length()


func remove_special_characters(old_string : String):
	var word_string = ""
	for character in old_string:
		if regex.search(character):
			word_string += character
		else:
			character = ""
			word_string += character
	#TODO: write the code
	
	return word_string


func _input(event : InputEvent) -> void:
	if active:
		if event.is_action_pressed("ui_cancel"):
			close()
		elif event.is_action_pressed("ui_commit"):
			_on_confirm_button_pressed()
		elif event is TypeKeyEvent and event.pressed:
			var old_caret_column = $NameEntry.caret_column
			if event.keycode == KEY_BACKSPACE:
				if old_caret_column > 0:
					$NameEntry.text = $NameEntry.text.erase(old_caret_column-1,1)
					$NameEntry.caret_column = old_caret_column - 1
					$NameKeySound.play()
			elif event.keycode == KEY_SPACE:
				$NameEntry.text = $NameEntry.text.insert(old_caret_column, " ")
				$NameEntry.caret_column = old_caret_column + event.key_string.length()
				$NameKeySound.play()
			elif regex.search(event.key_string):
				$NameEntry.text = $NameEntry.text.insert(old_caret_column, event.key_string)
				$NameEntry.caret_column = old_caret_column + event.key_string.length()
				$NameKeySound.play()


func _on_name_entry_gui_input(event : InputEvent):
	if event.is_action_pressed("ui_down"):
		$NameEntry.get_node($NameEntry.focus_neighbor_bottom).grab_focus.call_deferred()
	if event.is_action_pressed("ui_up"):
		$NameEntry.get_node($NameEntry.focus_neighbor_top).grab_focus.call_deferred()


func _on_decline_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_focus_next"):
		$TypeWriter.focus_key("A")


func _on_type_writer_left_neighbor_requested() -> void:
	$DeclineButton.grab_focus.call_deferred()
