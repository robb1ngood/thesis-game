extends GutTest

# A nyomógomb (puzzle_button.gd) egységtesztjei.

var PuzzleButtonScene = load("res://Scenes/PuzzleButton/puzzle_button.tscn")
var button = null

func before_each():
	# Minden teszt előtt új példányt hozunk létre a jelenetből, így minden teszt tiszta állapotból indul.
	button = PuzzleButtonScene.instantiate()
	
	# A gombot hozzáadjuk az aktív jelenetfához, hogy kezelni tudja a jeleket.
	# Az autofree() miatt a GUT a teszt végén felszabadítja a node-ot, így nem maradnak árva (orphan) node-ok.
	add_child(autofree(button))

# 1. teszteset: ha egy test rákerül a gombra, a gomb kiküldi a "pressed" jelet, és nő a testszámláló.
func test_button_pressed_signal_emitted_on_entry():
	# A GUT innentől figyeli a gomb által kiküldött jeleket.
	watch_signals(button)
	
	# Egy egyszerű Node2D játssza a gombra kerülő fizikai test szerepét; az autofree() itt is megelőzi a memóriaszivárgást.
	var dummy_body = autofree(Node2D.new())
	
	# A "pushable" csoportba tesszük, hogy a gomb szkriptje érvényes, lenyomásra képes testnek tekintse.
	dummy_body.add_to_group("pushable")
	
	# Kézzel hívjuk meg az ütközéskezelő függvényt a próbatesttel.
	button._on_body_entered(dummy_body)
	
	# Ellenőrizzük, hogy a gomb kiküldte a "pressed" jelet.
	assert_signal_emitted(button, "pressed")
	
	# Ellenőrizzük, hogy a belső számláló 1-re nőtt.
	assert_eq(button.bodies_on_top, 1)

# 2. teszteset: ha a test lekerül a gombról, a gomb kiküldi az "unpressed" jelet, és a számláló visszaáll.
func test_button_unpressed_signal_emitted_on_exit():
	# Figyelni kezdjük a gomb jeleit.
	watch_signals(button)
	
	# Létrehozzuk és beállítjuk a próbatestet.
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	# A teljes mozgást szimuláljuk: a test előbb rákerül a gombra, aztán lekerül róla.
	button._on_body_entered(dummy_body)
	button._on_body_exited(dummy_body)
	
	# Ellenőrizzük, hogy a test távozásakor a gomb kiküldte az "unpressed" jelet.
	assert_signal_emitted(button, "unpressed")
	
	# Ellenőrizzük, hogy a számláló visszaállt 0-ra.
	assert_eq(button.bodies_on_top, 0)

# 3. teszteset: az egyszer használatos gomb lenyomva marad, amikor a test lekerül róla.
func test_single_use_button_remains_pressed():
	# A teszt előtt bekapcsoljuk az exportált is_single_use tulajdonságot.
	button.is_single_use = true
	
	# Figyelni kezdjük a jeleket.
	watch_signals(button)
	
	# Létrehozzuk a próbatestet.
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	# A test rákerül a gombra, majd lekerül róla.
	button._on_body_entered(dummy_body)
	button._on_body_exited(dummy_body)
	
	# Az "unpressed" jel NEM mehet ki, mert az egyszer használatos gomb nem enged fel.
	assert_signal_not_emitted(button, "unpressed")
	
	# A számláló 1-en marad, mert a kilépéskezelő még a csökkentés előtt visszatér.
	assert_eq(button.bodies_on_top, 1)
