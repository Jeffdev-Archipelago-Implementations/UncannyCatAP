extends Menu
class_name APConnectScreen

@onready var ServerAddressBox = $ServerAddressBox as LineEdit
@onready var PortBox = $PortBox as LineEdit
@onready var SlotNameBox = $SlotNameBox as LineEdit
@onready var PasswordBox = $PasswordBox as LineEdit
@onready var ConnectBtn = $Connect as Button
@onready var ConnectInfoLabel = $ConnectionInfo as Label

var connecting: = false

func _ready() -> void :
	AP.inst.connected.connect(_on_ap_connected)
	AP.inst.connectionrefused.connect(_on_ap_connection_refused)
	AP.inst.connect_step.connect(_on_ap_connect_step)

	_prefill_from_save()

func _process(_delta: float) -> void :
	ConnectBtn.disabled = connecting or ServerAddressBox.text.is_empty() or PortBox.text.is_empty() or SlotNameBox.text.is_empty()

func _prefill_from_save() -> void :
	var last: = APConnectionMemory.load_last()
	if not last:
		return

	ServerAddressBox.text = last.ip
	PortBox.text = last.port
	SlotNameBox.text = last.slot
	PasswordBox.text = last.pwd

	if not last.seed_name.is_empty():
		ConnectInfoLabel.text = "Last played %s" % [last.slot]

func _on_confirm_pressed() -> void :
	connecting = true
	print("Connecting...")
	ConnectInfoLabel.text = "Connecting..."
	AP.inst.ap_connect(ServerAddressBox.text, PortBox.text, SlotNameBox.text, PasswordBox.text)

func _on_ap_connected(_conn: ConnectionInfo, _json: Dictionary) -> void :
	print("AP: connected, switching to main menu")
	switch.emit(Master.GameScenes.MAIN_MENU)

func _on_ap_connection_refused(_conn: ConnectionInfo, json: Dictionary) -> void :
	connecting = false
	var errors: Array = json.get("errors", [])
	print("AP: connection refused ", errors)
	ConnectInfoLabel.text = ("Refused: %s" % ", ".join(errors)) if errors else "Connection refused"

func _on_ap_connect_step(message: String) -> void :
	if connecting:
		ConnectInfoLabel.text = message

func _on_ap_bypass_pressed() -> void :
	print("Connect Bypass")
	switch.emit(Master.GameScenes.MAIN_MENU)
