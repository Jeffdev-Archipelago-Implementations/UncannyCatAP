@tool class_name APConsoleWindow extends Window
## The popup Archipelago console window.
##
## When the `display/window/subwindows/embed_subwindows` project setting is on (the
## default), this window is drawn inside the game's root viewport instead of getting a
## real OS window. That viewport can be much smaller than the console's design size -
## a 768x512 pixel-art viewport upscaled by `canvas_items` stretch, for instance - so
## the console would hang off every edge, title bar included, leaving it unreadable and
## impossible to drag back into view.
##
## While embedded, shrink to fit the host viewport and scale the console's content down
## by however much that viewport is being upscaled, which buys the UI back the layout
## room it needs and renders its text at the display's native resolution.

const DESIGN_SIZE := Vector2(1152, 648) ## Layout size the console UI is built for
const MIN_LAYOUT_SIZE := Vector2(750, 400) ## Smallest console layout that stays usable
const EMBED_MARGIN := 4.0 ## Host viewport pixels kept clear around an embedded console

var _native_min_size := Vector2i.ZERO

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_native_min_size = min_size
	var host := _host_viewport()
	if host is Window:
		(host as Window).size_changed.connect(fit_to_host)
	fit_to_host()

func _host_viewport() -> Viewport:
	var parent := get_parent()
	return parent.get_viewport() if parent else null

## Sizes and positions the console so it fits inside the viewport hosting it.
## Does nothing when the console has a real OS window of its own.
func fit_to_host() -> void:
	var host := _host_viewport()
	if not host or not is_embedded():
		min_size = _native_min_size
		content_scale_factor = 1.0
		return
	var host_size := host.get_visible_rect().size
	var avail := host_size - Vector2.ONE * (EMBED_MARGIN * 2.0)
	if avail.x < 1.0 or avail.y < 1.0: return

	# Stretch modes upscale the whole root viewport; scaling our content down by the
	# same factor undoes that, so console text lands on real pixels 1:1.
	var scale := 1.0 / _host_upscale(host)
	# ...but not so far down that the console gets less room than it needs.
	if avail.x / scale < MIN_LAYOUT_SIZE.x or avail.y / scale < MIN_LAYOUT_SIZE.y:
		scale = maxf(scale, minf(avail.x / MIN_LAYOUT_SIZE.x, avail.y / MIN_LAYOUT_SIZE.y))
	# No point growing the layout past the size the UI was designed at.
	var fit := Vector2(minf(avail.x, DESIGN_SIZE.x * scale), minf(avail.y, DESIGN_SIZE.y * scale))

	content_scale_factor = scale
	# The native minimum would fight a viewport this small; the scale handles it instead.
	min_size = Vector2i(MIN_LAYOUT_SIZE * scale)
	size = Vector2i(fit.floor())
	position = Vector2i(((host_size - fit) * 0.5).floor())

## How much the host viewport is being scaled up to reach the size it's displayed at.
func _host_upscale(host: Viewport) -> float:
	if not host is Window: return 1.0
	var vis := host.get_visible_rect().size
	if vis.x < 1.0 or vis.y < 1.0: return 1.0
	var real := Vector2((host as Window).size)
	return maxf(1.0, minf(real.x / vis.x, real.y / vis.y))
