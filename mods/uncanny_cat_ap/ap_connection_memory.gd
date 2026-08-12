class_name APConnectionMemory

const PATH: = "user://ap/last_connection.cfg"

static func store(seed_name: String) -> void :
	var creds: APCredentials = AP.inst.creds

	var conf: = ConfigFile.new()
	conf.set_value("connection", "ip", creds.ip)
	conf.set_value("connection", "port", creds.port)
	conf.set_value("connection", "slot", creds.slot)
	conf.set_value("connection", "pwd", creds.pwd)
	conf.set_value("connection", "seed", seed_name)

	DirAccess.make_dir_recursive_absolute(PATH.get_base_dir())
	var err: = conf.save(PATH)
	if err != OK:
		push_error("AP: failed to store last connection (error %d)" % err)

static func load_last() -> LastConnection:
	var conf: = ConfigFile.new()
	if conf.load(PATH) != OK:
		return null

	var last: = LastConnection.new()
	last.ip = conf.get_value("connection", "ip", "")
	last.port = conf.get_value("connection", "port", "")
	last.slot = conf.get_value("connection", "slot", "")
	last.pwd = conf.get_value("connection", "pwd", "")
	last.seed_name = conf.get_value("connection", "seed", "")

	return last if last.is_usable() else null


class LastConnection:
	var ip: String = ""
	var port: String = ""
	var slot: String = ""
	var pwd: String = ""
	var seed_name: String = ""

	# Enough to fill the connect screen with.
	func is_usable() -> bool:
		return not ip.is_empty() and not slot.is_empty()

	func _to_string() -> String:
		return "%s:%s %s @ %s" % [ip, port, slot, seed_name]
