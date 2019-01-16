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
	self.r.resize(maxVertices)
	seed(_seed)
	randi()
	for i in range(maxVertices):
		self.r[i] = rand_range(0, 1)
		#print("rand on i: ", i, " - ", self.r[i])
	
func mylerp(lo, hi, t):
	#var r = float(lo * (1 - t) + hi * t)
	#print("\t", lo, "|", hi, "|", t)
	return float(lo * (1 - t) + hi * t)
	
func smoothstepRemap(a, b, t):
	#print("smooooooth")
	var tSmoothstep = t * t * (3 - 2 * t)
	if (self._lerpImpl == lerpImpl.builtinLerp):
		return lerp(a, b, t)
	else:
		return self.mylerp(a, b, t)
		
func eval(x):
	var xi = int(floor(x))
	var t = float(x - xi)
	var xMin = xi & self.maxVerticesMask
	var xMax = (xMin + 1) & self.maxVerticesMask
	
	#print("\txi=", xi, "|t=", t, "|xMin=", xMin, "|xMax=", xMax)
	
	if (self._evalArt == evalArt.smoothstep):
		return self.smoothstepRemap(self.r[xMin], self.r[xMax], t);
	else:
		if (self._lerpImpl == lerpImpl.builtinLerp):
			return lerp(self.r[xMin], self.r[xMax], t)
		else:
			return self.mylerp(self.r[xMin], self.r[xMax], t)

