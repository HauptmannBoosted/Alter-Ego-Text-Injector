extends Control


# nodes
@onready var text_edit = $TextEdit
@onready var file_dialog = $FileDialog

# set a default path, if it does not exist, a file explorer will open on startup
var path : String = "C:\\Users\\<user>\\AppData\\Roaming\\Plogue\\Aria\\Presets\\com.Plogue.Talker\\GODOT_WRITE_TEXT_HERE_PRESET.ariap"


func _ready():
	# open file dialog and update path if default path does not exist
	if not FileAccess.file_exists(path):
		file_dialog.size = get_viewport_rect().size * 0.8
		file_dialog.popup()
		path = file_dialog.current_file

func _on_button_push_pressed():
	var xml_value : String = ""
	var trailer : String = ""
	var row_number : int = 0
	
	# create value to be inserted into the preset
	for row in text_edit.text.split("\n", true):
		row_number += 1
		
		if row_number == 1:
			trailer = "&#x0D;&#x0A;"
		elif row_number % 2 == 1:
			trailer = "&#x0D;"
		else:
			trailer = "&#x0A;"
		xml_value += row + trailer

	# fetch current file content (a preset has to exist beforehand, not just an empty file)
	var file_content = FileAccess.get_file_as_string(path)
	
	# compile new file content
	var new_file_content = ""
	for row in file_content.split("\n", true):
		if row.strip_edges().begins_with("<CustomData htype="):
			row = row.substr(0, '        <CustomData htype="9073" size="18" version="0" adata="'.length()) + xml_value + '"/>'
		new_file_content += row + "\n"
	
	# write file
	var access = FileAccess.open(path, FileAccess.WRITE)
	access.store_string(new_file_content)
	print("old contents: \n" + file_content)
	print("--------------------")
	print("new contents: \n", new_file_content)
	print("--------------------")

func _on_button_one_word_per_line_pressed():
	# split text into one word per line
	var text : String = text_edit.text
	text_edit.text = ""
	for word in text.split(' ', false, 127):
		text_edit.text += word + "\n"

func _on_button_close_pressed():
	get_tree().quit()

func _on_file_dialog_canceled():
	get_tree().quit()
