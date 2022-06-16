using ColorTypes: RGB
using ImageInTerminal
using Mitsuba2
import Mitsuba2.scalar_rgb as mitsuba
using PyCall: PyObject, PyNULL, pyimport
using Test



scene = mitsuba.load_file("test_scene.xml")

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

