extends Control

onready var canvas = get_node("CanvasLayer")
onready var inv = get_node("CanvasLayer/Panel/Inventory")

# unsere gespeicherten items in einem hash. { tileID => amount }
var items = {}

# fancy names, fürs visualisieren und die reihenfolge im inventar
var itemNames = [
	"Erde", "Stein", "Chronataphor", "Betamaramor", "Beletum", "Remarophos", "Tizener", "Cobgorop", "Meddl"
]

# methode die nach jeder änderung des inventars aufgerufen wird.
# bewirkt das die ItemList so geändert wird das der aktuelle stand visualisiert wird
func updateItemView():
	for i in range(itemNames.size()):
		if items[itemNames[i]] > 0:
			inv.set_item_text(i, itemNames[i] + " (" + str(items[itemNames[i]]) + ")")
		else:
			inv.set_item_text(i, itemNames[i] + " (-)")
	pass

# fügt ein item <type> (tileName) mit der anzahl <amount> dem inventar hinzu
func addItem(type, amount):
	if type == "grassblock":
		items["Erde"] += amount
	else:
		items[type] += amount
	self.updateItemView()

# gibt zurück wieviele items von einem typ im inventar liegen (ID)
# gibt -1 zurück wenn ein fehler auftrat
func getItemAnz(type):
	if items.has(type):
		return items[type]
	else:
		return -1

# entfernt ein item <type> (tileName) mit der anzahl <amount> aus dem inventar
# gibt 0 zurück wenn alles gut ging
# gibt die anzahl die vorhanden sind wenn nicht alle entfernt werden können (entfernt aber nichts!)
# gibt -1 zurück wenn ein fehler vorlag
func removeItem(type, amount):
	if ((items[type] - amount) < 0):
		return items[type]
	items[type] -= amount
	updateItemView()
	return 0

# initalizierung des items arrays sowie hiden des inventars
func _ready():
	for i in range(itemNames.size()):
		items[itemNames[i]] = 0
	updateItemView()
	canvas.set_scale(Vector2(0, 0))
	self.set_process(true)

# gibt true zurück wenn das inventar sichtbar ist, ansonsten false
func IsGuiVisble():
	return canvas.scale.x == 1

# gibt true zurück wenn die console den fokus hat, ansonsten false
func ConsoleHasFocus():
	var console = get_node("CanvasLayer/CheatCon/Console")
	return console.has_focus()

# update bei jedem frame, prüfen ob die sichtbarkeit des inventars geändert werden muss
func _process(delta):
	if (Input.is_action_just_pressed("show_inventar") and (not ConsoleHasFocus())):
		if canvas.scale.x == 0:
			canvas.set_scale(Vector2(1, 1))
		else:
			get_node("CanvasLayer/RobotronView/bohrerPan").visible = false
			get_node("CanvasLayer/RobotronView/jetpackPan").visible = false
			get_node("CanvasLayer/RobotronView/bootPan").visible = false
			canvas.set_scale(Vector2(0, 0))
	
	if (canvas.scale.x == 1 and Input.is_action_just_pressed("ui_cancel")):
		get_node("CanvasLayer/RobotronView/bohrerPan").visible = false
		get_node("CanvasLayer/RobotronView/jetpackPan").visible = false
		get_node("CanvasLayer/RobotronView/bootPan").visible = false
		canvas.set_scale(Vector2(0, 0))
	
	if (canvas.scale.x == 1 and Input.is_action_just_pressed("toggle_debug")):
		var debugMode = not ProjectSettings.get("debugMode")
		ProjectSettings.set("debugMode", debugMode)
		get_node("CanvasLayer/CheatCon").visible = debugMode
		get_node("../HUD/TextEdit").visible = debugMode
#endFUNC
	
#========================================================
# signal handler
#========================================================

# ausgabe an die konsolenhistorie
func conOut(line):
	var conHi = get_node("CanvasLayer/CheatCon/ConHi")
	conHi.newline()
	conHi.append_bbcode(line)

# signal (callback) vom consoleninput, vearbeitet konsolen-befehle
func _on_Console_text_entered(new_text):
	var cmds = new_text.split(" ")
	if (cmds[0] == "give"):
		if cmds.size() < 3:
			conOut("usage: give <type> <amount>")
			return
		#endIF
		conOut(new_text)
		self.addItem(cmds[1], int(cmds[2]))
	elif (cmds[0] == "giveAll"):
		for iN in self.itemNames:
			self.items[iN] += 9999
		#endFOR
		conOut(new_text)
		self.updateItemView()
	elif (cmds[0] == "setBohrer"):
		if cmds.size() < 3:
			conOut("usage: setBohrer <cooldown> <maxDist>")
			return
		#endIF
		conOut(new_text)
		var player = ProjectSettings.get("player")
		player.updateBohrer({
			"cooldown": float(cmds[1]),
			"maxDist" : float(cmds[2])
		})
	elif (cmds[0] == "setJetpack"):
		if cmds.size() < 3:
			conOut("usage: setJetpack <maxFlyTime> <eps>")
			return
		#endIF
		conOut(new_text)
		var player = ProjectSettings.get("player")
		player.updateJetpack({
			"maxFlyTime": float(cmds[1]),
			"eps" : float(cmds[2])
		})
	elif (cmds[0] == "fly"):
		conOut(new_text)
		if (cmds[1] == "on"):
			ProjectSettings.set("endlessJetpack", true)
		else:
			ProjectSettings.set("endlessJetpack", false)
	elif (cmds[0] == "setSpeed"):
		if cmds.size() < 2:
			conOut("usage: setSpeed <speed>")
			return
		#endIF
		conOut(new_text)
		var player = ProjectSettings.get("player")
		player.updateBoots({
			"speed": float(cmds[1])
		})
	#endIF
	var console = get_node("CanvasLayer/CheatCon/Console")
	console.release_focus()
	console.set_text("")
#endFUNC

#========================================================

# callback fürs öffnen der upgradeliste für den bohrer, schließt alle anderen upgradelisten
func _on_btnBohrer_pressed():
	get_node("Upgrades").updateTT_bohrer()
	var n = get_node("CanvasLayer/RobotronView/bohrerPan")
	n.visible = !n.visible
	get_node("CanvasLayer/RobotronView/jetpackPan").visible = false
	get_node("CanvasLayer/RobotronView/bootPan").visible = false
	pass

# callback fürs öffnen der upgradeliste für den jetpack, schließt alle anderen upgradelisten
func _on_btnTorso_pressed():
	get_node("Upgrades").updateTT_jetpack()
	get_node("CanvasLayer/RobotronView/bohrerPan").visible = false
	var n = get_node("CanvasLayer/RobotronView/jetpackPan")
	n.visible = !n.visible
	get_node("CanvasLayer/RobotronView/bootPan").visible = false
	pass

# callback fürs öffnen der upgradeliste für die schuhe, schließt alle anderen upgradelisten
func _on_btnFuesse_pressed():
	get_node("Upgrades").updateTT_boots()
	get_node("CanvasLayer/RobotronView/bohrerPan").visible = false
	get_node("CanvasLayer/RobotronView/jetpackPan").visible = false
	var n = get_node("CanvasLayer/RobotronView/bootPan")
	n.visible = !n.visible
	pass
