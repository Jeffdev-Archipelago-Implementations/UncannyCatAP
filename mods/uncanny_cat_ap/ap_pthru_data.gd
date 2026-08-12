extends PthruData
class_name APPthruData

## Class for handling AP specific pthru data.

## Loads this room's run, or starts one if the folder is empty.
static func open(slot_name: String) -> APPthruData:
	if not AP.inst or not AP.inst.is_ap_connected():
		return null

	var pthru: = APPthruData.new()

	var existing: Array[PthruData] = Master.save_data.pthrus
	if existing.is_empty():
		pthru.modifiers = Modifiers.new()
		print("AP: starting a new run")
	else:
		# Carries 'pthru_id' across too, so it keeps writing to the same file
		pthru._copy_from(existing[0])
		print("AP: resuming run \"%s\"" % pthru.pthru_name)

	pthru.pthru_name = "Archipelago"
	pthru.player_name = slot_name

	var slot: Dictionary = AP.inst.conn.slot_data
	pthru.modifiers.mods["easy_mode"] = bool(int(slot.get("chill_mode", 0)))
	pthru.modifiers.mods["hard_mode"] = bool(int(slot.get("panic_mode", 0)))

	pthru.save_to_file()

	existing.clear()
	existing.append(pthru)

	return pthru


func _copy_from(other: PthruData) -> void :
	for prop in other.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			set(prop.name, other.get(prop.name))
