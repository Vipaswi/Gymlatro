extends TextureRect

func _ready():
	get_node("/root/Node2D/TextureRect2").texture = get_node("/root/Node2D/SubViewportContainer/SubViewport").get_texture()
	print(get_node("/root/Node2D/SubViewportContainer/SubViewport").get_texture().get_size())
