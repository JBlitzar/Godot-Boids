extends Node3D


# References to the compute shader and buffers
var computeShader: RDShaderFile
@export var amount = 100
# Simulation boundary variables
var boundaryMin = Vector3(-10, -10, -10)
var boundaryMax = Vector3(10, 10, 10)
var positions = []
var velocities = []
# Create a local rendering device.
var rd := RenderingServer.create_local_rendering_device()
var shader_file := load("res://boids_compute.glsl")
var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
var shader := rd.shader_create_from_spirv(shader_spirv)

func _ready():
	
	
	randomize()
	# Initialize positions and velocities with random values within the boundaries
	for i in range(amount):
		var randomPosition = Vector3(
			randf_range(boundaryMin.x, boundaryMax.x),
			randf_range(boundaryMin.y, boundaryMax.y),
			randf_range(boundaryMin.z, boundaryMax.z)
		)
		positions.append(randomPosition)

		"""var randomVelocity = Vector3(
			randf_range(-0.010, -0.01),
			randf_range(-0.010, -0.01),
			randf_range(-0.010, -0.01)
		).normalized()"""
		
		velocities.append(Vector3(1,0,0))
	$Control.init_debugpanels(amount)
	print(positions)
	tick(0.1)
	print(positions)
	

func arrayToBuffer(items) -> RID:
	var bytes := PackedVector3Array(items).to_byte_array()
	return rd.storage_buffer_create(bytes.size(), bytes)

func createUniform(binding, buffer) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding
	uniform.add_id(buffer)
	return uniform


func getOutput(buffer):
		var output_bytes := rd.buffer_get_data(buffer)
		var output := output_bytes.to_float32_array()
		var vectorArray: Array = []
		# Convert floatArray to vectorArray
		for i in range(0, output.size(), 3):
			var x = output[i]#clampf(output[i],-10,10)
			var y = output[i+1]#clampf(output[i+1],-10,10)
			var z = output[i+2]#clampf(output[i+2],-10,10)
			var vector = Vector3(x, y, z)
			vectorArray.append(vector)
		return vectorArray
func tick(delta):
	#begin shader setup
		
	
	
	var positionBuffer := arrayToBuffer(positions)
	var velocityBuffer := arrayToBuffer(velocities)
	
	# Create a uniform to assign the buffer to the rendering device
	var Puniform := createUniform(0, positionBuffer)
	var Vuniform := createUniform(1, velocityBuffer)
	
	var uniform_set := rd.uniform_set_create([Puniform, Vuniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, amount, 1, 1)
	rd.compute_list_end()
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
	
	var newPositions = getOutput(positionBuffer)
	var newVelocities = getOutput(velocityBuffer)
	
	
	for i in range(min(amount, $MultiMeshInstance3D.multimesh.instance_count)):
		var pos = Transform3D()
		
		pos = pos.translated(newPositions[i])
		$MultiMeshInstance3D.multimesh.set_instance_transform(i, pos)
	positions = newPositions
	velocities = newVelocities
	$Control.update_debugpanels(positions, velocities)
		

func _process(delta):
	tick(delta)
	
