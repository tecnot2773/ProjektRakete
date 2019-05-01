extends Node

# bohrerupgrades: maximale reichweite, cooldown (aka abbaugeschwindigkeit)
var bohrerUpgrades = [
	{
		"name"		: "Normal",
		"icon"		: "Bohrer_Overdrive_0_600.png",
		"zutaten"	: null,
		"mod"	: {
			"cooldown": 0.8,
			"maxDist": 200
		},
		"bought"	: true
	},
	{
		"name"		: "Chrona-Bohrer",
		"icon"		: "Bohrer_Overdrive_1_600.png",
		"zutaten"	: [
			[ "Erde", 11 ],
			[ "Stein", 16 ],
			[ "Chronataphor", 8 ]
		],
		"mod"	: {
			"cooldown": 0.6,
			"maxDist": 400
		},
		"bought"	: false
	},
	{
		"name"		: "Tiz-Bohrer",
		"icon"		: "Bohrer_Overdrive_2_600.png",
		"zutaten"	: [
			[ "Beletum", 18 ],
			[ "Stein", 23 ],
			[ "Tizener", 14 ]
		],
		"mod"	: {
			"cooldown": 0.3,
			"maxDist": 600
		},
		"bought"	: false
	}
];

var jetpack_upgrades = [
	{
		"name"		: "Normal",
		"icon"		: "tank_0_small.png",
		"zutaten"	: null,
		"mod"		: {
			"maxFlyTime": 2,
			"eps"		: 9
		},
		"bought"	: true
	},
	{
		"name"		: "ChronoTiz Tank v1",
		"icon"		: "tank_1_small.png",
		"zutaten"	: [
			[ "Stein", 6 ],
			[ "Beletum", 12 ],
			[ "Chronataphor", 8],
			[ "Tizener", 6]
		],
		"mod"		: {
			"maxFlyTime": 10,
			"eps"		: 10
		},
		"bought"	: false
	},
	{
		"name"		: "Cobgo-Remar Tank",
		"icon"		: "tank_3_small.png",
		"zutaten"	: [
			[ "Stein", 12 ],
			[ "Cobgorop", 23 ],
			[ "Remarophos", 18 ]
		],
		"mod"		: {
			"maxFlyTime": 30,
			"eps"		: 19
		},
		"bought"	: false
	}
];

var bootUpgrades = [
	{
		"name"		: "Normal",
		"icon"		: "boots_0_small.png",
		"zutaten"	: null,
		"mod" 		: { "speed": 190 },
		"bought"	: true
	},
	{
		"name"		: "Speedy",
		"icon"		: "boots_1_small.png",
		"zutaten"	: [
			[ "Stein", 9 ],
			[ "Betamaramor", 12 ],
			[ "Chronataphor", 10 ]
		],
		"mod" 		: { "speed": 320 },
		"bought"	: false
	},
	{
		"name"		: "Flash",
		"icon"		: "boots_2_small.png",
		"zutaten"	: [
			[ "Stein", 15 ],
			[ "Beletum", 23 ],
			[ "Tizener", 16 ]
		],
		"mod" 		: { "speed": 520 },
		"bought"	: false
	},
];

onready var inv = get_node("../")

func checkCanBuy(upgrade):
	var canBuy = true
	for z in upgrade["zutaten"]:
		if (inv.getItemAnz(z[0]) < z[1]):
			canBuy = false
	return canBuy

# updated die tooltips und enabelt items wenn sie kaufbereit sind
func updateTT(upgrades, itemlistPath):
	var itemList = get_node(itemlistPath)
	for i in range(upgrades.size()):
		var u = upgrades[i]
		if u["zutaten"] == null:
			itemList.set_item_tooltip(i, "Kostenlos")
		else:
			var s = ""
			var canBuy = true
			for z in u["zutaten"]:
				s += z[0] + " (" + str(inv.getItemAnz(z[0])) + "/" + str(z[1]) + ") "
				if (inv.getItemAnz(z[0]) < z[1]):
					canBuy = false
			if (not u["bought"]):
				if (canBuy):
					itemList.set_item_custom_bg_color(i, Color("#007700"))
					itemList.set_item_disabled(i, false)
				else:
					itemList.set_item_custom_bg_color(i, Color("#770000"))
					itemList.set_item_disabled(i, true)
			#endFor
			itemList.set_item_tooltip(i, s)
		#endIf
	#endFor
	pass

func initItemList(upgrades, itemListPath):
	var n = get_node(itemListPath)
	for i in range(upgrades.size()):
		var u = upgrades[i]
		if u["icon"] != null:
			n.add_item(u["name"], load("res://textures/upgrades/" + str(u["icon"])))
		else:
			n.add_item(u["name"])
		#endIF
		
		if i > 0:
			n.set_item_disabled(i, true)
		#endIF
	#endFor
	n.select(0)
	pass

func updateTT_bohrer():
	updateTT(bohrerUpgrades, "../CanvasLayer/RobotronView/bohrerPan/ItemList")

func updateTT_jetpack():
	updateTT(jetpack_upgrades, "../CanvasLayer/RobotronView/jetpackPan/ItemList")
	
func updateTT_boots():
	updateTT(bootUpgrades, "../CanvasLayer/RobotronView/bootPan/ItemList")

func _ready():
	
	#init bohrer upgrades
	ProjectSettings.get("player").updateBohrer(bohrerUpgrades[0]["mod"])
	initItemList(bohrerUpgrades, "../CanvasLayer/RobotronView/bohrerPan/ItemList")
	updateTT_bohrer()
	
	#init jetpack upgrades
	ProjectSettings.get("player").updateJetpack(jetpack_upgrades[0]["mod"])
	initItemList(jetpack_upgrades, "../CanvasLayer/RobotronView/jetpackPan/ItemList")
	updateTT_jetpack()
	
	#init boot's upgrades
	ProjectSettings.get("player").updateBoots(bootUpgrades[0]["mod"])
	initItemList(bootUpgrades, "../CanvasLayer/RobotronView/bootPan/ItemList")
	updateTT_boots()

	pass
#endFunc

#========================================================
# signal handler
#========================================================

func _on_bohrer_item_selected(index):
	var itemList = get_node("../CanvasLayer/RobotronView/bohrerPan/ItemList");
	if itemList.is_item_disabled(index):
		return
	
	var u = bohrerUpgrades[index]
	if self.checkCanBuy(u):
		itemList.set_item_disabled(index - 1, true)
		itemList.set_item_custom_bg_color(index, Color(0, 0, 0, 0))
		ProjectSettings.get("player").updateBohrer(u["mod"])
	pass


func _on_jetpack_item_selected(index):
	var itemList = get_node("../CanvasLayer/RobotronView/jetpackPan/ItemList");
	if itemList.is_item_disabled(index):
		return
	
	var u = jetpack_upgrades[index]
	if self.checkCanBuy(u):
		itemList.set_item_disabled(index - 1, true)
		itemList.set_item_custom_bg_color(index, Color(0, 0, 0, 0))
		ProjectSettings.get("player").updateJetpack(u["mod"])
	pass


func _on_boot_item_selected(index):
	var itemList = get_node("../CanvasLayer/RobotronView/bootPan/ItemList");
	if itemList.is_item_disabled(index):
		return
	
	var u = bootUpgrades[index]
	if self.checkCanBuy(u):
		itemList.set_item_disabled(index - 1, true)
		itemList.set_item_custom_bg_color(index, Color(0, 0, 0, 0))
		ProjectSettings.get("player").updateBoots(u["mod"])
	pass
