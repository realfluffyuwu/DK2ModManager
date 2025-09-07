extends Panel


var mod_name: String = ""
var mod_id: String = ""

@onready var modname: Label = $BoxContainer/modname
@onready var source: Label = $BoxContainer/source

func construct(m_name: String, id: String) -> void:
	mod_name = m_name
	modname.text = "Name: {0}".format([mod_name])
	mod_id = id

	if mod_id == "0":
		$openinworkshop.hide()
		source.text = "Source: Local"
	else:
		source.text = "Source: Workshop"

func _on_openinworkshop_pressed() -> void:
	OS.shell_open("steam://openurl/https://steamcommunity.com/workshop/filedetails/?id={0}".format([mod_id]))
