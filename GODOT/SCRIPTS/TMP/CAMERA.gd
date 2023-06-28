# Source: https://www.youtube.com/watch?v=Jd0en-xC3bk
extends Camera2D

var TargetNodePath = NodePath("../PAPA_CHARACTERS")
var target_node
#export (float) var lerpspeed = 0.15

func _ready():
	target_node = get_node(TargetNodePath)
	
func _process(_delta):
#	self.position = lerp(self.position, target_node.position, lerpspeed)
	self.position = target_node.position
