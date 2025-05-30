@static_unload
class_name Logger

static var content:PackedStringArray
static var path:String
static var enable_print:bool
static var enable_auto_save:bool
var owner:String

static func setup(save_path = \
"user://game_log/%s.log" % Time.get_date_string_from_system() \
, isprint = true, auto_save = true):
	content = PackedStringArray()
	enable_print = isprint
	path = save_path
	enable_auto_save = auto_save

func _init(from):
	owner = from

func normal(message):
	content.append("[{time}][常规]<{from}>:{mes}".format({"time":Time.get_datetime_string_from_system().replace("T","_"),"from":owner,"mes":message}))
	if (enable_print):
		print(content[-1])
	if (enable_auto_save):
		Util.add_file(path,content[-1])

func warn(message):
	content.append("[{time}][警告]<{from}>:{mes}".format({"time":Time.get_datetime_string_from_system().replace("T","_"),"from":owner,"mes":message}))
	if (enable_print):
		print(content[-1])
	if (enable_auto_save):
		Util.add_file(path,content[-1])

func error(message):
	content.append("[{time}][错误]<{from}>:{mes}".format({"time":Time.get_datetime_string_from_system().replace("T","_"),"from":owner,"mes":message}))
	if (enable_print):
		print(content[-1])
	if (enable_auto_save):
		Util.add_file(path,content[-1])

func debug(message):
	content.append("[{time}][调试]<{from}>:{mes}".format({"time":Time.get_datetime_string_from_system().replace("T","_"),"from":owner,"mes":message}))
	if (enable_print):
		print(content[-1])
	if (enable_auto_save):
		Util.add_file(path,content[-1])
