extends TileMapLayer

# This script is shared by two layers in the first scene:
#   - HiddenTreeBlockPuzzle/SecretTree   -> disable_tree / enable_tree
#   - IceBlockPuzzle/MossyLogObstacle    -> disable_mossy_log

func disable_tree():
	visible = false
	collision_enabled = false

func enable_tree():
	visible = true
	collision_enabled = true

func disable_mossy_log():
	disable_tree()
