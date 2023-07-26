extends Control

@export var BoidDebugPanel: PackedScene

func init_debugpanels(amount):
	for i in range(amount):
		var instance = BoidDebugPanel.instantiate()
		$VBoxContainer.add_child(instance)

func update_debugpanels(positions, velocities):
	for i in range(len(positions)):
		var child = $VBoxContainer.get_child(i)
		child.get_node("Label").text = " id: "+str(i)+"\n position: "+str(positions[i])+"\n velocity: "+str(velocities[i])
