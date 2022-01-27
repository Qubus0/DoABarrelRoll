tool
extends EditorPlugin

var editor: Node = null
var editors = {}

func _enter_tree() -> void:
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	script_editor.connect("editor_script_changed", self, "editor_script_changed")
	get_all_text_editors(script_editor)


func _exit_tree() -> void:
	# do a barrel roll!
	pass


func do_a_barrel_roll():
	var editor = get_editor_interface()
	var control = editor.get_base_control()
	control.rect_pivot_offset =  control.rect_size / 2
	var tween = Tween.new()
	control.add_child(tween)
	tween.interpolate_property(control, "rect_rotation", 0, 360, 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(2.0), "timeout")
	tween.queue_free()


# following code in parts from https://github.com/jotson/ridiculous_coding
func editor_script_changed(script):
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()

	editors.clear()
	get_all_text_editors(script_editor)


func get_all_text_editors(parent : Node):
	for child in parent.get_children():
		if child.get_child_count():
			get_all_text_editors(child)

		if child is TextEdit:
			if child.is_connected("text_changed", self, "text_changed"):
				child.disconnect("text_changed", self, "text_changed")
			child.connect("text_changed", self, "text_changed", [child])


func text_changed(textedit : TextEdit):
	var editor = get_editor_interface()

	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them
		editors.clear()
		get_all_text_editors(editor.get_script_editor())

	var line = textedit.cursor_get_line()
	var line_text = textedit.get_line(line)
	if '#' in line_text and "barrel" in line_text and "roll" in line_text:
		do_a_barrel_roll()

