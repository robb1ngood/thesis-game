extends GutTest

var manager = null

func before_each():
	manager = autofree(load("res://Scenes/SceneManager/scene_manager.gd").new())

func test_door_is_only_saved_once():
	manager.open_door("/root/Test/Door")
	manager.open_door("/root/Test/Door")
	assert_eq(manager.opened_doors.size(), 1)

func test_kill_emits_signal_with_total():
	watch_signals(manager)
	manager.register_kill("/root/Test/Enemy1")
	manager.register_kill("/root/Test/Enemy2")
	assert_signal_emit_count(manager, "enemy_killed", 2)
	assert_eq(manager.enemies_killed, 2)

func test_reset_run_clears_everything():
	manager.opened_chests.append("chest1")
	manager.register_kill("/root/Test/Enemy1")
	manager.complete_quest("lumberjack_logs")
	manager.has_weapon = true
	manager.player_hp = 1
	manager.reset_run()
	assert_eq(manager.opened_chests.size(), 0)
	assert_eq(manager.killed_enemies.size(), 0)
	assert_eq(manager.enemies_killed, 0)
	assert_false(manager.is_quest_complete("lumberjack_logs"))
	assert_false(manager.has_weapon)
	assert_eq(manager.player_hp, 4)
