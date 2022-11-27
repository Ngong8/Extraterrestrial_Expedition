extends TileMap
class_name WorldGen

var noise : OpenSimplexNoise = OpenSimplexNoise.new() #Terrain Noise Variable
var cave_noise : OpenSimplexNoise = OpenSimplexNoise.new() #Cave Noise Variable
var ore_noise : OpenSimplexNoise = OpenSimplexNoise.new() #Cave Noise Variable
export var x_length : int = 256 #World Length
export var y_depth : int = 256 #World Depth
export var height : int = 128 #World Height
var water_level : int
export var buffer_height : int = 10
const SPRITE_RES = preload("res://Scenes/TileSetSpriteTest.tscn")

var cell_names : Dictionary = {"dirt":0, "grass0":5, "grass1":10, "grass2":15, "stone":20, "milkore":27, "darkdirt":35, "cyangrass0":40, "cyangrass1":45, "cyangrass2":50, "basalt":55, "shinyore":64, "magmaore":72}

var biome_data : Dictionary = {
	"plains": ["grass0","grass1","grass2","dirt"],
	"cyan_plains": ["cyangrass0","cyangrass1","cyangrass2","darkdirt"],
	"milkore_scatter": ["milkore","stone"],
	"shinyore_scatter": ["shinyore","stone"],
}

var temperature = {}
var biome : Array = []
func _ready():
	var mid_y_depth : int = y_depth - 100
	randomize() #Randomize the internal game seed
	noise.get_seamless_image(512)
	noise.seed = randi()
	noise.octaves = 8
	noise.persistence = 0.6
	noise.lacunarity = 1.25
	noise.period = 512
	cave_noise.get_seamless_image(64)
	cave_noise.seed = randi()
	cave_noise.octaves = 5
	cave_noise.persistence = 1.0
	cave_noise.lacunarity = 1.4
	cave_noise.period = 128 #The farther away from zero the smoother the terrain is going to look
	ore_noise.seed = randi()
	ore_noise.octaves = 9
	ore_noise.persistence = 0
	ore_noise.lacunarity = 0.1
	ore_noise.period = 6.6 #The farther away from zero the smoother the terrain is going to look
	generate_map()
	
#	#Set the seed as random numbers
#	noise.seed = randi()
#	noise.octaves = 8
#	noise.persistence = 0.6
#	noise.lacunarity = 1.0
#	noise.period = 512 #The farther away from zero the smoother the terrain is going to look

	
#	for x in range(-x_length,x_length): #Loop through the X length starting from negative to positive
#		var y = ceil(noise.get_noise_1d(x) * height) #Get the noise at the given length and multiply it by the height then round it
#		# From here, for surface and a bit depth for grasses and dirts in different biomes
##		if x <= x_length - 60: 
#		if y >= 0.1:	# Assume regular biome
#			# Random grasses here:
#			var random_grass = cell_names.values()
#			random_grass.erase(cell_names.milkore)
#			random_grass.erase(cell_names.stone)
#			random_grass.erase(cell_names.dirt)
#			random_grass.erase(cell_names.darkdirt)
#			random_grass.erase(cell_names.cyangrass0)
#			random_grass.erase(cell_names.cyangrass1)
#			random_grass.erase(cell_names.cyangrass2)
##			print_debug(random_grass)
#			random_grass.shuffle()
#			set_cellv(Vector2(x,y),random_grass[0]) #Set the cell at the given X and Y
#			# Finally, dirts for a bit depth
#			for depth in range(y,y+buffer_height): #Fill in air gaps with dirt starting from the Y value to n blocks down (buffer height)
#				if get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
#					set_cellv(Vector2(x,depth),cell_names.dirt)
#		else:	# Assume other biome
#			# Random grasses here:
#			var random_grass = cell_names.values()
#			random_grass.erase(cell_names.milkore)
#			random_grass.erase(cell_names.stone)
#			random_grass.erase(cell_names.dirt)
#			random_grass.erase(cell_names.darkdirt)
#			random_grass.erase(cell_names.grass0)
#			random_grass.erase(cell_names.grass1)
#			random_grass.erase(cell_names.grass2)
##			print_debug(random_grass)
#			random_grass.shuffle()
#			set_cellv(Vector2(x,y),random_grass[0]) #Set the cell at the given X and Y
#			# Finally, dirts for a bit depth
#			for depth in range(y,y+buffer_height): #Fill in air gaps with dirt starting from the Y value to n blocks down (buffer height)
#				if get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
#					set_cellv(Vector2(x,depth),cell_names.darkdirt)
#		# Starts from here coding is for more depth with stone blocks
#		for depth in range(y+buffer_height,y_depth-40): #Generate stone n blocks (buffer height) down from the given Y value
#			set_cellv(Vector2(x,depth),cell_names.stone)
#			var a = rand_range(-100,100)
#			if a >= 75:
#				set_cellv(Vector2(x,depth),cell_names.milkore)
#
#		for depth in range(y,y_depth): #Start from the Y and go down to the Y depth
#			var yy = cave_noise.get_noise_2d(x,depth) #Get 2d noise from the given X and Y value
#
#			if abs(yy) < .05: #Check if the absolute value of the noise is less than .05
#				set_cellv(Vector2(x,depth + y),-1) #Remove the block at the given X and Y value
#		for bedrock_depth in range(y_depth-40, y_depth):
#			set_cellv(Vector2(x,bedrock_depth),cell_names.stone)
#


func generate_map() -> void:
	var grid_name : Dictionary = {}
	for x in range(-x_length,x_length): #Loop through the X length starting from negative to positive
		var y = ceil(noise.get_noise_1d(x) * height) #Get the noise at the given length and multiply it by the height then round it
		# From here, for surface and a bit depth for grasses and dirts in different biomes
		if x > -x_length + 50 and x < x_length - 50:	# Assume regular biome
			# Random grasses here:
			biome = biome_data.plains
			var random_grass : Array = biome
			random_grass.erase("dirt")
			random_grass.shuffle()
			set_cellv(Vector2(x,y),cell_names[random_grass[0]]) #Set the cell at the given X and Y
			# Finally, dirts for a bit depth
			for depth in range(y,y+buffer_height): #Fill in air gaps with dirt starting from the Y value to n blocks down (buffer height)
				if get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
					set_cellv(Vector2(x,depth),cell_names.dirt)
		else:	# Assume other biome
			# Random grasses here:
			biome = biome_data.cyan_plains
			var random_grass : Array = biome
			random_grass.erase("darkdirt")
			random_grass.shuffle()
			set_cellv(Vector2(x,y),cell_names[random_grass[0]]) #Set the cell at the given X and Y
			# Finally, dirts for a bit depth
			for depth in range(y,y+buffer_height): #Fill in air gaps with dirt starting from the Y value to n blocks down (buffer height)
				if get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
					set_cellv(Vector2(x,depth),cell_names.darkdirt)
		# Starts from here coding is for more depth with stone blocks
		for depth in range(y+buffer_height,y_depth-40): #Generate stone n blocks (buffer height) down from the given Y value
			set_cellv(Vector2(x,depth),cell_names.stone) # Finally, spawn a block whether is stone or ore!
		for depth in range(y,y_depth): #Start from the Y and go down to the Y depth
			var yy = cave_noise.get_noise_2d(x,depth) #Get 2d noise from the given X and Y value
			if abs(yy) < .05: #Check if the absolute value of the noise is less than .05
				set_cellv(Vector2(x,depth + y),-1) #Remove the block at the given X and Y value
		for bedrock_depth in range(y_depth-40, y_depth):
			set_cellv(Vector2(x,bedrock_depth),cell_names.stone)
	# Spawn ores in different depths
	for x in range(-x_length, x_length):
		for y in y_depth - 40:
			if get_cell(x,y) == cell_names.stone:
				var ore_y = ore_noise.get_noise_2d(x,y)
				if ore_y > 0.5:
					var percent : int = (float(y) / float(y_depth)) * 100
					var oreID = cell_names.stone
					if percent in range(0,100):
						if y <= y_depth / 2:
							if rand_range(0,1) > 0.2:
								oreID = cell_names.milkore
							else:
								oreID = cell_names.stone
						elif y > y_depth / 2 and y <= y_depth / 1.25:
							if rand_range(0,1) > 0.75:
								oreID = cell_names.milkore
							else:
								oreID = cell_names.shinyore
						else:
							if rand_range(0,1) > 0.45:
								oreID = cell_names.shinyore
							else:
								oreID = cell_names.magmaore
					set_cellv(Vector2(x,y), oreID)
	return


func between(val, start, end):
	if start <= val and val < end:
		return true
