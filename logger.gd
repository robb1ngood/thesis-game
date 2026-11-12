extends CanvasLayer

var _file: FileAccess
var _timer: float = 0.0
@onready var _label: Label = $Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label.visible = false
	_file = FileAccess.open("user://perf_log.csv", FileAccess.WRITE)
	_file.store_line("time_s,fps,frame_ms,mem_mb,draw_calls,nodes")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		_label.visible = not _label.visible

func _process(delta: float) -> void:
	_timer += delta
	if _timer < 1.0:
		return
	_timer = 0.0
	var fps: float = Performance.get_monitor(Performance.TIME_FPS)
	var frame_ms: float = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var mem_mb: float = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	var draws: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var nodes: float = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	_file.store_line("%d,%d,%.2f,%.1f,%d,%d" % [Time.get_ticks_msec() / 1000, fps, frame_ms, mem_mb, draws, nodes])
	_file.flush()
	_label.text = "FPS %d | %.1f ms | %.0f MB" % [fps, frame_ms, mem_mb]
