extends Sprite2D


# Called when the node enters the scene tree for the first time.
var noise_tex
func _ready() -> void:
	noise_tex = NoiseTexture2D.new()
	noise_tex.noise = FastNoiseLite.new()
	noise_tex.noise.frequency = 0.05
	noise_tex.seamless = true
	material.set_shader_parameter("NOISE_PATTERN", noise_tex)



# Called every frame. 'delta' is the elapsed time since the previous frame.
var time = 0
func _process(delta: float) -> void:
	time+=delta
	noise_tex.noise.cellular_jitter=fmod(time,2)-1
