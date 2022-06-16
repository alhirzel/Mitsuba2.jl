using ColorTypes: RGB
using ImageInTerminal
using Mitsuba2
import Mitsuba2.scalar_rgb as mitsuba
using PyCall: PyObject, PyNULL, pyimport
using Test



const test_scene_xml = """
<scene version="2.0.0">
	<shape type="sphere">
		<bsdf type="diffuse"/>
	</shape>
	<integrator type="path"/>
	<emitter type="point">
		<rgb name="intensity" value="200,0,0"/>
		<point name="position" x="2" y="0" z="2"/>
	</emitter>
	<emitter type="point">
		<rgb name="intensity" value="0,0,200"/>
		<point name="position" x="2" y="0" z="-2"/>
	</emitter>
	<sensor type="perspective">
		<transform name="to_world">
			<lookat origin="4, 0, 0" target="0, 0, 0" up="0, 0, 1"/>
		</transform>
		<film type="hdrfilm">
			<integer name="width" value="256"/>
			<integer name="height" value="256"/>
		</film>
		<sampler type="ldsampler">
			<integer name="sample_count" value="256" />
		</sampler>
	</sensor>
</scene>
"""



scene = mitsuba.load_string(test_scene_xml)

@testset "load a basic scene" begin
	@test scene != PyNULL()
	@test scene isa PyObject
end

sensor = first(scene.sensors())

@testset "render the scene" begin
	@test scene.integrator().render(scene, sensor) # true means success
	@test sensor.film().size() == [256, 256]
end

img = sensor.film().bitmap(raw=true)

# TODO - factor this into the package
img = img.convert(mitsuba.Bitmap.PixelFormat.RGB, mitsuba.Struct.Type.Float32, srgb_gamma=false)
img = mapslices(Base.splat(RGB), pyimport("numpy").array(img; copy=false); dims=(3,))[:, :, 1]

display(img)
println("")

