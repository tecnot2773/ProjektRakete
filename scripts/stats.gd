extends VBoxContainer

var stat = {}

func collectItem(name, value):
	changeStat("Blöcke abgebaut", 1)
	
	if (name == "grassblock"):
		changeStat("Grassblöcke gesammelt", value)
		return
	changeStat(name + " gesammelt", value)

func changeStat(name, value):
	self.stat[name] += value
	updateTable()

func updateTable():
	for i in range(self.stat.size()):
		get_child(i * 2).get_child(1).text = str(self.stat.values()[i])
		pass
	#endFOR
#endFUNC

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# save our stats!
		var f = File.new()
		f.open("./stats.cfg", File.WRITE)
		for s in self.stat:
			f.store_line(s + "=" + str(self.stat[s]))
		f.close()
		pass

func _ready():
	self.stat["Blöcke abgebaut"] = 0
	self.stat["Erde gesammelt"] = 0
	self.stat["Grassblöcke gesammelt"] = 0
	self.stat["Stein gesammelt"] = 0
	self.stat["Chronataphor gesammelt"] = 0
	self.stat["Cobgorop gesammelt"] = 0
	self.stat["Beletum gesammelt"] = 0
	self.stat["Betamaramor gesammelt"] = 0
	self.stat["Remarophos gesammelt"] = 0
	self.stat["Tizener gesammelt"] = 0
	self.stat["Meddl gesammelt"] = 0
	
	# load from file
	var f = File.new()
	if f.file_exists("./stats.cfg"):
		f.open("./stats.cfg", File.READ)
		while not f.eof_reached():
			var data = f.get_line().split('=')
			if len(data) >= 2:
				print("load stat: " + data[0] + "\t" + data[1])
				self.stat[data[0]] = int(data[1])
			pass
		#endWHILE
		f.close()
	#endIF
		
	# init table
	var _p = Panel.new()
	var st = StyleBoxFlat.new()
	st.set_bg_color(Color("777777"))
	_p.add_stylebox_override("panel", st)
	_p.set_custom_minimum_size(Vector2(0, 1))
		
	for i in range(self.stat.size()):
		var n = HBoxContainer.new()
		
		var _l1 = Label.new()
		_l1.text = self.stat.keys()[i]
		_l1.size_flags_horizontal = SIZE_EXPAND_FILL
		n.add_child( _l1 )
		
		var _l2 = Label.new()
		_l2.text = str(self.stat.values()[i])
		n.add_child( _l2 )
		
		self.add_child(n)
		
		if i < self.stat.size()-1:
			self.add_child(_p.duplicate(DUPLICATE_USE_INSTANCING))
	#endFOR
#endFUNC