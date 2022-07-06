using ColorTypes: RGB
using ImageInTerminal
using Mitsuba2

using PyCall: PyObject, PyNULL, pyimport
using Test

for variant in Mitsuba2.variants()
    @testset "variant $variant" begin
        @eval import Mitsuba2.$(Symbol(variant)) as mitsuba

        scene = mitsuba.load_string(read("test_scene.xml", String))

        @testset "load a basic scene" begin
            @test scene != PyNULL()
            @test scene isa PyObject
        end

        sensor = first(scene.sensors())

        @testset "render the scene" begin
            @test scene.integrator().render(scene, sensor) # true means success
            @test sensor.film().size() == [256, 256]
        end

        bmp = sensor.film().bitmap(raw=true)

        # TODO - factor this into the package
        bmp = bmp.convert(mitsuba.Bitmap.PixelFormat.RGB, mitsuba.Struct.Type.Float32, srgb_gamma=false)

        raw = pyimport("numpy").array(bmp; copy=false)
        raw .+= minimum(raw)
        raw ./= maximum(raw)
        img = mapslices(Base.splat(RGB), raw; dims=(3,))[:, :, 1]
        using FileIO
        save("test_scene.png", img)

        display(img)
        println("")
    end
end

