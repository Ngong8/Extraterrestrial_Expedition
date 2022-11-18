extends TileMap

var noise : OpenSimplexNoise = OpenSimplexNoise.new() #Terrain Noise Variable
var cave_noise : OpenSimplexNoise = OpenSimplexNoise.new() #Cave Noise Variable
export var x_length : int = 256 #World Length
export var y_depth : int = 256 #World Depth
export var height : int = 128 #World Height
var water_level : int
export var buffer_height : int = 10
const SPRITE_RES = preload("res://Scenes/TileSetSpriteTest.tscn")

var cell_names : Dictionary = {"dirt":0, "grass0":5, "grass1":10, "grass2":15, "stone":20, "milkore":27}
var last_near_border_block_height : int
func _ready():
	randomize() #Randomize the internal game seed

	#Set the seed as random numbers
	noise.seed = randi()
	noise.octaves = 8
	noise.persistence = 0.6
	noise.lacunarity = 1.0
	noise.period = 512 #The farther away from zero the smoother the terrain is going to look
	cave_noise.seed = randi()
	cave_noise.octaves = 5
	cave_noise.persistence = 0.6
	cave_noise.lacunarity = 1.8
	cave_noise.period = 100 #The farther away from zero the smoother the terrain is going to look
	
	for x in range(-x_length,x_length): #Loop through the X length starting from negative to positive
		var y = ceil(noise.get_noise_1d(x) * height) #Get the noise at the given length and multiply it by the height then round it
		# From here, for surface and a bit depth for grasses and dirts in different biomes
		if x <= x_length - 60: # Assume regular biome
			# Random grasses here:
			var random_grass = cell_names.values()
			random_grass.erase(cell_names.milkore)
			random_grass.erase(cell_names.stone)
			random_grass.erase(cell_names.dirt)
#			print_debug(random_grass)
			random_grass.shuffle()
			set_cellv(Vector2(x,y),random_grass[0]) #Set the cell at the given X and Y
			# Finally, dirts for a bit depth
			for depth in range(y,y+buffer_height): #Fill in air gaps with dirt starting from the Y value to n blocks down (buffer height)
				if get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
					set_cellv(Vector2(x,depth),cell_names.dirt)
			last_near_border_block_height = y
		else: # Assume different biome(s)
			var static_y : int = last_near_border_block_height
			set_cellv(Vector2(x,static_y),cell_names.stone) #Set the cell at the given X and Y
			# Finally, stones for a bit depth
			for depth in range(static_y,static_y+buffer_height): #Fill in air gaps with stone starting from the Y value to n blocks down (buffer height)
				if get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
					set_cellv(Vector2(x,depth),cell_names.stone)

		# Starts from here coding is for more depth with stone blocks
		for depth in range(y+buffer_height,y_depth-40): #Generate stone n blocks (buffer height) down from the given Y value
			set_cellv(Vector2(x,depth),cell_names.stone)
		for depth in range(y_depth-40,y_depth):
			set_cellv(Vector2(x,depth),cell_names.milkore)

		for depth in range(y+5,y_depth): #Start from the Y and go down to the Y depth
			var yy = cave_noise.get_noise_2d(x,depth) #Get 2d noise from the given X and Y value

			if abs(yy) < .05: #Check if the absolute value of the noise is less than .03
				set_cellv(Vector2(x,depth + y),-1) #Remove the block at the given X and Y value

