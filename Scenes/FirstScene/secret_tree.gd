extends TileMapLayer

# Elrejti a réteget, és kikapcsolja az ütközését.
func disable_tree():
	visible = false
	collision_enabled = false

# Újra megjeleníti a réteget, és visszakapcsolja az ütközését.
func enable_tree():
	visible = true
	collision_enabled = true

# A mohás farönk ugyanúgy tűnik el, mint a fa.
func disable_mossy_log():
	disable_tree()
