extends TextEdit

# ersetzt eine zeile wenn die zeile vorhanden ist. wenn nicht, 
# wird die zeile erschaffen
func replaceLine(lineNum, new_line):
	#if lineNum != 0:
	#print("-> replaceLine (", lineNum, ", '", new_line, "')")
	
	var lines = null
	#if self.text == "":
	lines = self.text.split('\n')
	#else:
	#	lines = PoolStringArray()
	
	#print("\t lines: ", str(len(lines)))
	#if (len(lines) < lineNum):
	#	print("\t lines are to few... add some!")
	#	for i in range(lineNum + 1):
	#		lines.push_back("")
		#endFor
	#endIF
	lines.set(lineNum, new_line)
	
	self.text = lines.join("\n")
#endFUNC

func _ready():
	pass
