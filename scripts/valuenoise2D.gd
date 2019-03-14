#extends Node

var maxVertices = 0
var maxVerticesMask = 0
var r = []
var _lerpImpl = lerpImpl.myLerp
var _evalArt = evalArt.hard

enum lerpImpl {
	myLerp, builtinLerp
}

enum evalArt {
	hard, smoothstep
}

func _init(_seed, maxVertices = 256):
	self.maxVertices = maxVertices
	self.maxVerticesMask = maxVertices - 1
	self.r.resize(maxVertices * maxVertices)
	seed(_seed)
	randi()
	for i in range(maxVertices * maxVertices):
		self.r[i] = rand_range(0, 1)
		#print("rand on i: ", i, " - ", self.r[i])
	
func mylerp(lo, hi, t):
	#var r = float(lo * (1 - t) + hi * t)
	#print("\t", lo, "|", hi, "|", t)
	return float(lo * (1 - t) + hi * t)
	
func smoothstep(t):
	return (t * t * (3 - 2 * t))
	
func smoothstepRemap(a, b, t):
	var tSmoothstep = t * t * (3 - 2 * t)
	if (self._lerpImpl == lerpImpl.builtinLerp):
		return lerp(a, b, t)
	else:
		return self.mylerp(a, b, t)
		
func eval(x, y):
	var xi = int(floor(x))
	var yi = int(floor(y))
	
	var tx = float(x - xi)
	var ty = float(y - yi)
	
	var xMin = xi & self.maxVerticesMask
	var xMax = (xMin + 1) & self.maxVerticesMask
	
	var yMin = yi & self.maxVerticesMask
	var yMax = (yMin + 1) & self.maxVerticesMask
	
	#print("\txi=", xi, "|t=", t, "|xMin=", xMin, "|xMax=", xMax)
	
	#if (self._evalArt == evalArt.smoothstep):
	#	return self.smoothstepRemap(self.r[xMin], self.r[xMax], t);
	#else:
	#	if (self._lerpImpl == lerpImpl.builtinLerp):
	#		return lerp(self.r[xMin], self.r[xMax], t)
	#	else:
	#		return self.mylerp(self.r[xMin], self.r[xMax], t)
	
	var c00 = self.r[yMin * self.maxVerticesMask + xMin]
	var c10 = self.r[yMin * self.maxVerticesMask + xMax]
	var c01 = self.r[yMax * self.maxVerticesMask + xMin]
	var c11 = self.r[yMax * self.maxVerticesMask + xMax]
	
	var sx = self.smoothstep(tx)
	var sy = self.smoothstep(ty)
	
	var nx0 = lerp(c00, c10, sx)
	var nx1 = lerp(c01, c11, sx)
	
	return lerp(nx0, nx1, sy)

