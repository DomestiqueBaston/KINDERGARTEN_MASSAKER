# Source: https://www.youtube.com/watch?v=Jd0en-xC3bk
extends Camera2D

var TargetNodePath = NodePath("../PAPA_PLAYER")
var target_node

func _ready():
	target_node = get_node(TargetNodePath)
	
func _process(_delta):
	self.position = target_node.position
