tool
extends EditorPlugin

var editor: Node = null
var editors = {}

var accepting_input := true

func _enter_tree() -> void:
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	script_editor.connect("editor_script_changed", self, "editor_script_changed")
	get_all_text_editors(script_editor)


func _exit_tree() -> void:
	# do a barrel roll!
	# do a flip!
	pass


func do_a_barrel_roll() -> void:
	accepting_input = false

	var duration_seconds := 2.0
	var editor := get_editor_interface()
	var control := editor.get_base_control()
	control.rect_pivot_offset = control.rect_size / 2

	var tween = Tween.new()
	control.add_child(tween)
	tween.interpolate_property(control, "rect_rotation", 0, 360, duration_seconds, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(2.0), "timeout")
	tween.queue_free()

	accepting_input = true


func do_a_flip() -> void:
	accepting_input = false

	var duration_seconds := 1.5
	var editor := get_editor_interface()
	var control := editor.get_base_control()
	control.rect_pivot_offset = control.rect_size / 2

	var tween = Tween.new()
	control.add_child(tween)
	tween.interpolate_property(control, "rect_scale", Vector2(1, 1), Vector2(1, -1), duration_seconds/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(control, "rect_scale", Vector2(1, -1), Vector2(1, 1), duration_seconds/2, Tween.TRANS_CUBIC, Tween.EASE_OUT, duration_seconds/2)
	tween.start()
	yield(get_tree().create_timer(duration_seconds), "timeout")
	tween.queue_free()

	accepting_input = true


# following code in parts from https://github.com/jotson/ridiculous_coding
func editor_script_changed(script):
	var editor := get_editor_interface()
	var script_editor := editor.get_script_editor()

	editors.clear()
	get_all_text_editors(script_editor)


func get_all_text_editors(parent : Node) -> void:
	for child in parent.get_children():
		if child.get_child_count():
			get_all_text_editors(child)

		if child is TextEdit:
			if child.is_connected("text_changed", self, "text_changed"):
				child.disconnect("text_changed", self, "text_changed")
			child.connect("text_changed", self, "text_changed", [child])


func text_changed(textedit : TextEdit) -> void:
	if not accepting_input: # avoid triggering the tweens multiple times
		return

	var editor := get_editor_interface()

	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them
		editors.clear()
		get_all_text_editors(editor.get_script_editor())

	var line := textedit.cursor_get_line()
	var line_text := textedit.get_line(line).to_lower()
	line_text = remove_strings(line_text) 	# lines with "#" trigger otherwise

	var segments := line_text.split("#")
	segments.remove(0) 	# segment 0 is before the # -> not a comment

	if segments.size() > 0:
		for segment in segments:
			if "barrel roll" in segment:
				do_a_barrel_roll()
			if "flip" in segment:
				do_a_flip()


func remove_strings(string: String) -> String:
	var re = RegEx.new()
	re.compile("\".*?\"")
	string = re.sub(string, '')
	re.compile("'.*?'")
	string = re.sub(string, '')
	return string

