extends Control

export(int, "Overlapping,Tiled") var rect_type : int

export(NodePath) var source_image_rect_path : NodePath
export(NodePath) var result_image_rect_path : NodePath
export(NodePath) var settings_label_path : NodePath

var _current_data_index : int = -1

enum SampleDataType {
	SAMPLE_DATA_TYPE_OVERLAPPING = 0,
	SAMPLE_DATA_TYPE_TILED = 1,
};

class TileEntry:
	var tile_name : String = ""
	var symmetry : int = 0
	var weight : float = 1
	var image : Image
	var images : Array
	
	func _to_string():
		var t : String = ""
		
		if image:
			t = "simple"
		else:
			t = "complex (" + str(images.size()) + ")"
		
		return "[ TileEntry " + t + " tile_name: " + tile_name + ", symmetry: " + str(symmetry) + " weight: " + str(weight) + " ]\n"

class NeighbourEntry:
	var left : String = ""
	var left_orientation : int = 0
	var right : String = ""
	var right_orientation : int = 0
	
	func setup(l : String, r : String):
		left = l.get_slice(" ", 0)
		var s : String = l.get_slice(" ", 1)
		if (s != ""):
			left_orientation = int(s)
		
		right = r.get_slice(" ", 0)
		
		s = r.get_slice(" ", 1)
		if (s != ""):
			right_orientation = int(s)
	
	func _to_string():
		return "[ NeighbourEntry left: " + left + "(" + str(left_orientation) + "), right: " + right + "(" + str(right_orientation) + ") ]\n"

class SampleData:
	var type : int = 0
	var image_name : String = ""
	var pattern_size : int = 3
	var periodic : bool = false
	var width : int = 0
	var height : int = 0
	var symmetry : int = 8
	var ground : bool = false
	var limit : int = 0
	var screenshots : int = 0
	var periodic_input : int = true
	var tiles : Array
	var neighbours : Array
	var image : Image
	
	func _to_string():
		return "SampleData\ntype: " + str(type) + \
			"\nimage_name: " + image_name + \
			"\npattern_size: " + str(pattern_size) + \
			"\nperiodic: " + str(periodic) + \
			"\nwidth: " + str(width) + \
			"\nheight: " + str(height) + \
			"\nsymmetry: " + str(symmetry) + \
			"\nground: " + str(ground) + \
			"\nlimit: " + str(limit) + \
			"\nscreenshots: " + str(screenshots) + \
			"\nperiodic_input: " + str(periodic_input) + \
			"\ntiles: " + str(tiles) + \
			"\nneighbours: " + str(neighbours)

var data : Array

func _init():
	load_data()
	
func load_data():
	data.clear()
	
	var xmlp : XMLParser = XMLParser.new()
	xmlp.open("res://samples/samples.xml")
	
	while xmlp.read() == OK:
		if xmlp.get_node_type() == XMLParser.NODE_ELEMENT:
			if xmlp.get_node_name() == "overlapping" || xmlp.get_node_name() == "simpletiled":
				var entry : SampleData = SampleData.new()
				
				if xmlp.get_node_name() == "overlapping":
					entry.type = SampleDataType.SAMPLE_DATA_TYPE_OVERLAPPING
				else:
					entry.type = SampleDataType.SAMPLE_DATA_TYPE_TILED
				
				for i in range(xmlp.get_attribute_count()):
					var attrib_name : String = xmlp.get_attribute_name(i)
					var attrib_value : String = xmlp.get_attribute_value(i)
					
					if attrib_name == "name":
						entry.image_name = attrib_value
					elif attrib_name == "N":
						entry.pattern_size = int(attrib_value)
					elif attrib_name == "periodic":
						if attrib_value == "True":
							entry.periodic = true
						else:
							entry.periodic = false
					elif attrib_name == "width":
						entry.width = int(attrib_value)
					elif attrib_name == "height":
						entry.height = int(attrib_value)
					elif attrib_name == "symmetry":
						entry.symmetry = int(attrib_value)
					elif attrib_name == "ground":
						entry.ground = int(attrib_value)
					elif attrib_name == "limit":
						entry.limit = int(attrib_value)
					elif attrib_name == "screenshots":
						entry.screenshots = int(attrib_value)
					elif attrib_name == "periodic_input":
						entry.periodic_input = int(attrib_value)
				
				if entry.type == SampleDataType.SAMPLE_DATA_TYPE_TILED:
					var e : Array = load_tile_entry(entry)
					entry.tiles = e[0]
					entry.neighbours = e[1]
				else:
					entry.image = ResourceLoader.load("res://samples/" + entry.image_name + ".png")
					
				data.push_back(entry)

func load_tile_entry(entry : SampleData) -> Array:
	var xmlp : XMLParser = XMLParser.new()
	xmlp.open("res://samples/" + entry.image_name + "/data.xml")
	
	var tiles : Array
	var neighbours : Array
	
	while xmlp.read() == OK:
		if xmlp.get_node_type() == XMLParser.NODE_ELEMENT:
			if xmlp.get_node_name() == "tile":
				var e : TileEntry = TileEntry.new()
				
				for i in range(xmlp.get_attribute_count()):
					var attrib_name : String = xmlp.get_attribute_name(i)
					var attrib_value : String = xmlp.get_attribute_value(i)
					
					if attrib_name == "name":
						e.tile_name = attrib_value
					elif attrib_name == "symmetry":
						
						if attrib_value == "X":
							e.symmetry = WaveFormCollapse.SYMMETRY_X
						elif attrib_value == "T":
							e.symmetry = WaveFormCollapse.SYMMETRY_T
						elif attrib_value == "I":
							e.symmetry = WaveFormCollapse.SYMMETRY_I
						elif attrib_value == "L":
							e.symmetry = WaveFormCollapse.SYMMETRY_L
						elif attrib_value == "\\":
							e.symmetry = WaveFormCollapse.SYMMETRY_BACKSLASH
						elif attrib_value == "P":
							e.symmetry = WaveFormCollapse.SYMMETRY_P
						
					elif attrib_name == "weight":
						e.weight = float(attrib_value)
						
				var simple_image_path : String = "res://samples/" + entry.image_name + "/" + e.tile_name + ".png"
				
				var file : File = File.new()
				if !file.file_exists(simple_image_path):
					var indx : int = 0
					while true:
						var image_path : String = "res://samples/" + entry.image_name + "/" + e.tile_name + " " + str(indx) + ".png"
						
						if !file.file_exists(image_path):
							break
							
						e.images.push_back(ResourceLoader.load(image_path))
						indx += 1
				else:
					e.image = ResourceLoader.load(simple_image_path)
					
					
					
				tiles.push_back(e)
			elif xmlp.get_node_name() == "neighbor":
				var e : NeighbourEntry = NeighbourEntry.new()
				
				var left : String
				var right : String
				
				for i in range(xmlp.get_attribute_count()):
					var attrib_name : String = xmlp.get_attribute_name(i)
					var attrib_value : String = xmlp.get_attribute_value(i)
					
					if attrib_name == "left":
						left = attrib_value
					elif attrib_name == "right":
						right = attrib_value
				
				e.setup(left, right)
				neighbours.push_back(e)
				
					
	return [ tiles, neighbours ]


func _enter_tree():
	_on_next_pressed()

func generate_image():
	if (rect_type == SampleDataType.SAMPLE_DATA_TYPE_OVERLAPPING):
		generate_image_overlapping()
	else:
		generate_image_tiled()

func generate_image_overlapping():
	get_node(source_image_rect_path).texture = null
	get_node(result_image_rect_path).texture = null
	
	var sd : SampleData = data[_current_data_index]
	
	get_node(settings_label_path).text = str(_current_data_index) + "\n" + sd.to_string()
	
	var indexer : ImageIndexer = ImageIndexer.new()
	
	var source_tex : ImageTexture = ImageTexture.new();
	source_tex.create_from_image(sd.image, 0)
	get_node(source_image_rect_path).texture = source_tex
	
	var indices : PoolIntArray = indexer.index_image(sd.image)
	
	var wfc : OverlappingWaveFormCollapse = OverlappingWaveFormCollapse.new()
	wfc.pattern_size = sd.pattern_size
	wfc.periodic_output = sd.periodic
	wfc.symmetry = sd.symmetry
	wfc.ground = sd.ground

	wfc.periodic_input = sd.periodic_input

	wfc.out_height = sd.image.get_height()
	wfc.out_width = sd.image.get_width()
	
	wfc.set_input(indices, sd.image.get_width(), sd.image.get_height())
	
	#todo
	#if sd.width > 0 && sd.height > 0:
	#	wfc.set_input(indices, sd.width, sd.height)
	#else:
	#	wfc.set_input(indices, img.get_width(), img.get_height())
	
	randomize()
	wfc.set_seed(randi())
	
	wfc.initialize()
	
	var res : PoolIntArray = wfc.generate_image_index_data()
	
	if (res.size() == 0):
		print("(res.size() == 0)")
		return
	
	var data : PoolByteArray = indexer.indices_to_argb8_data(res)
	
	var res_img : Image = Image.new()
	res_img.create_from_data(sd.image.get_width(), sd.image.get_height(), false, Image.FORMAT_RGBA8, data)
	
	var res_tex : ImageTexture = ImageTexture.new();
	res_tex.create_from_image(res_img, 0)
	
	get_node(result_image_rect_path).texture = res_tex

func generate_image_tiled():
	get_node(source_image_rect_path).texture = null
	get_node(result_image_rect_path).texture = null
	
	var sd : SampleData = data[_current_data_index]
	
	get_node(settings_label_path).text = str(_current_data_index) + "\n" + sd.to_string()

	var indexer : ImageIndexer = ImageIndexer.new()
	var wfc : TilingWaveFormCollapse = TilingWaveFormCollapse.new()
	
	var img_size : int = 0
	
	for i in range(sd.tiles.size()):
		var te : TileEntry = sd.tiles[i]
		
		if !te.image:
			var tile_index : int = wfc.tile_add(te.symmetry, te.weight)
			wfc.tile_name_set(tile_index, te.tile_name)
			wfc.tile_symmetry_set(tile_index, te.symmetry)
			
			for img in te.images:
				if img_size == 0:
					img_size = img.get_height()
					
				var indices : PoolIntArray = indexer.index_image(img)
				wfc.tile_data_add(tile_index, indices, img.get_width(), img.get_height())
		else:
			if img_size == 0:
					img_size = te.image.get_height()
					
			var indices : PoolIntArray = indexer.index_image(te.image)
			var tile_index : int = wfc.tile_add_generated(indices, te.image.get_width(), te.image.get_height(), te.symmetry, te.weight)
			wfc.tile_name_set(tile_index, te.tile_name)

	
	for i in range(sd.neighbours.size()):
		var ne : NeighbourEntry = sd.neighbours[i]

		wfc.neighbour_data_add_str(ne.left, ne.left_orientation, ne.right, ne.right_orientation)
	
	wfc.periodic_output = sd.periodic
	
	wfc.wave_width = sd.width
	wfc.wave_height = sd.height
	
	#todo
	#if sd.width > 0 && sd.height > 0:
	#	wfc.set_input(indices, sd.width, sd.height)
	#else:
	#	wfc.set_input(indices, img.get_width(), img.get_height())
	
	randomize()
	wfc.set_seed(randi())
	
	wfc.initialize()
	
	var res : PoolIntArray = wfc.generate_image_index_data()
	
	if (res.size() == 0):
		print("(res.size() == 0)")
		return
		
	var data : PoolByteArray = indexer.indices_to_argb8_data(res)
	
	var res_img : Image = Image.new()
	res_img.create_from_data(sd.width * img_size, sd.height * img_size, false, Image.FORMAT_RGBA8, data)
	
	var res_tex : ImageTexture = ImageTexture.new();
	res_tex.create_from_image(res_img, 0)
	
	get_node(result_image_rect_path).texture = res_tex


func _on_prev_pressed():
	while true:
		_current_data_index -= 1
		
		if _current_data_index < 0:
			_current_data_index = data.size() - 1
			
		if data[_current_data_index].type == rect_type:
			break
			
	generate_image()

func _on_next_pressed():
	while true:
		_current_data_index += 1
		
		if _current_data_index >= data.size():
			_current_data_index = 0
			
		if data[_current_data_index].type == rect_type:
			break
		
	generate_image()

func _on_tiled_toggled(on : bool):
	if !on:
		return
	
	rect_type = 1
	
	_current_data_index = -1
	
	_on_next_pressed()
	
func _on_overlapping_toggled(on : bool):
	if !on:
		return
		
	rect_type = 0
	
	_current_data_index = -1
	
	_on_next_pressed()

func _on_randomize_pressed():
	generate_image()
