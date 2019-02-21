#extends Node

func smoothstep(t):
	return t * t * (3 - 2 * t);
	
func quintic(t):
	return t * t * t * (t * (t * 6 - 15) + 10);
	
func smoothstepDeriv(t):
	return t * (6 - 6 * t);
	
func quinticDeriv(t):
	return 30 * t * t * (t * (t - 2) + 1);
	
const tableSize = 256;
const tableSizeMask = tableSize - 1;
var gradients = [];
var permutationTable = [];
	
func dice():
	return randf();
	
func diceInt():
	return randi();
	
func myswap(i, j):
	var c = self.permutationTable[i];
	self.permutationTable[i] = self.permutationTable[j];
	self.permutationTable[j] = c;
	
func _init(_seed = 2016):
	#array init
	self.gradients.resize(tableSize);
	self.permutationTable.resize(tableSize * 2);
	
	#original init
	seed(_seed);
	for i in range(tableSize):
		var thera = acos(2 * dice() - 1);
		var phi = 2 * dice() * M_PI;
		var x = cos(phi) * sin(theta);
		var y = sin(phi) * sin(theta);
		var z = cos(theta);
		self.gradients[i] = Vector3(x, y, z);
		self.permutationTable[i] = i;
	
	for i in range(tableSize):
		myswap(i, diceInt() & tableSizeMask);
		
	for i in range(tableSize):
		self.permutationTable[tableSize + i] = self.permutationTable[i]
	
func eval(p, derivs):
	var xi0 = ((int) floor(p.x)) & tableSizeMask;
	var yi0 = ((int) floor(p.y)) & tableSizeMask;
	var zi0 = ((int) floor(p.z)) & tableSizeMask;
	
	var xi1 = (xi0 + 1) & tableSizeMask;
	var yi1 = (yi0 + 1) & tableSizeMask;
	var zi1 = (zi0 + 1) & tableSizeMask;
	
	var tx = p.x - ((int) floor(p.x));
	var ty = p.y - ((int) floor(p.y));
	var tz = p.z - ((int) floor(p.z));
	
	var u = quintic(tx);
	var v = quintic(ty);
	var w = quintic(tz);
	
	var x0 = tx, x1 = tx - 1;
	var y0 = ty, y1 = ty - 1;
	var z0 = tz, z1 = tz - 1;
	
	var a = gradientDotV(myhash(xi0, yi0, zi0), x0, y0, z0);
	var b = gradientDotV(myhash(xi1, yi0, zi0), x1, y0, z0);
	var c = gradientDotV(myhash(xi0, yi1, zi0), x0, y1, z0);
	var d = gradientDotV(myhash(xi1, yi1, zi0), x1, y1, z0);
	var e = gradientDotV(myhash(xi0, yi0, zi1), x0, y0, z1);
	var f = gradientDotV(myhash(xi1, yi0, zi1), x1, y0, z1);
	var g = gradientDotV(myhash(xi0, yi1, zi1), x0, y1, z1);
	var h = gradientDotV(myhash(xi1, yi1, zi1), x1, y1, z1);
	
	var k0 = a;
	var k1 = (b - a);
	var k2 = (c - a);
	var k3 = (e - a);
	var k4 = (a + d - b - c);
	var k5 = (a + f - b - e);
	var k6 = (a + g - c - e);
	var k7 = (b + c + e + h - a - d - f - g);
	
	derivs.x = du *(k1 + k4 * v + k5 * w + k7 * v * w);
	derivs.y = dv *(k2 + k4 * u + k6 * w + k7 * v * w);
	derivs.z = dw *(k3 + k5 * u + k6 * v + k7 * v * w);
	
	return k0 + k1 * u + k2 * v + k3 * w + k4 * u * v + k5 * u * w + k6 * v * w + k7 * u * v * w;
	
func myhash(x, y, z):
	return self.permutationTable[self.permutationTable[self.permutationTable[x] + y] + z];

func gradientDotV(perm, x, y, z):
	pass
	
	
#http://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_basics.html#match
#https://www.scratchapixel.com/code.php?id=57&origin=/lessons/procedural-generation-virtual-worlds/perlin-noise-part-2














