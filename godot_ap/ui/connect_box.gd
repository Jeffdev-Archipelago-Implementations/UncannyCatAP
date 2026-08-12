extends GridContainer

@onready var ipbox: LineEdit = $IP_Box
@onready var portbox: LineEdit = $Port_Box
@onready var slotbox: LineEdit = $Slot_Box
@onready var pwdbox: LineEdit = $Pwd_Box
@onready var errlbl: Label = $ErrorLabel

func _ready() -> void:
	AP.inst.creds.updated.connect(refresh_creds)
	refresh_creds(AP.inst.creds)
	AP.inst.connected.connect(func(_conn,_json): update_connection(true))
	AP.inst.disconnected.connect(func(): update_connection(false))
func refresh_creds(creds: APCredentials) -> void:
	ipbox.text = creds.ip
	portbox.text = creds.port
	slotbox.text = creds.slot
	pwdbox.text = creds.pwd

func update_connection(status: bool) -> void:
	ipbox.editable = not status
	portbox.editable = not status
	slotbox.editable = not status
	pwdbox.editable = not status
func try_connection() -> void:
	if AP.inst.is_not_connected():
		AP.inst.ap_connect(ipbox.text, portbox.text, slotbox.text, pwdbox.text)
		_connect_signals()

func kill_connection() -> void:
	AP.inst.ap_disconnect()

func _connect_signals() -> void:
	if not AP.inst.connected.is_connected(_on_connect_success):
		AP.inst.connected.connect(_on_connect_success)
	if not AP.inst.connectionrefused.is_connected(_on_connect_refused):
		AP.inst.connectionrefused.connect(_on_connect_refused)
func _disconnect_signals() -> void:
	AP.inst.connected.disconnect(_on_connect_success)
	AP.inst.connectionrefused.disconnect(_on_connect_refused)
func _on_connect_success(_conn: ConnectionInfo, _json: Dictionary) -> void:
	_disconnect_signals()
	errlbl.text = ""
func _on_connect_refused(_conn: ConnectionInfo, json: Dictionary) -> void:
	_disconnect_signals()
	errlbl.text = "ERROR: " + (", ".join(json.get("errors", ["Unknown"])))
