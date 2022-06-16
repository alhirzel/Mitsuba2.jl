baremodule Mitsuba2

using Base: @eval
using PyCall: pyimport



# list of things to export; each will be allocated then updated in __init__
let mitsuba_module_name = "mitsuba",
	variants = pyimport(mitsuba_module_name).variants(),
	core_imports = [
		:Bitmap, :FileResolver, :filesystem, :Float, :Frame3f, :Logger,
		:Spectrum, :Ray3f, :Struct, :Thread, :Vector2f, :Vector3f,
	],
	render_imports = [
		:BSDF, :BSDFContext, :Emitter, :Film, :Film, :ImageBlock, :Integrator,
		:PhaseFunction, :Sampler, :Scene, :Sensor, :Shape, :SurfaceInteraction3f,
		:Texture, :Volume,
	],
	all_imports = [core_imports..., render_imports...]

	# allows callers to use it
	@eval variants() = $(variants)

	for variant in variants
		@eval baremodule $(Symbol(variant))

			using Base: copy!
			using PyCall: PyNULL, @py_str, pyimport

			# this is the general pattern that is used to expose mitsuba
			load_dict = load_file = load_string = PyNULL()
			export load_dict, load_file, load_string

			$( [:(const $(sym) = PyNULL()) for sym in all_imports]... )
			$( [:(export $(sym)) for sym in all_imports]... )

			# set all of the PyNULLs to the real PyObjects
			function __init__()
				mitsuba = pyimport($(mitsuba_module_name))
				mitsuba.set_variant($(variant))
				$( [:(copy!($(sym), mitsuba.core.$(sym))) for sym in core_imports]... )
				$( [:(copy!($(sym), mitsuba.render.$(sym))) for sym in render_imports]... )
				copy!(load_dict, mitsuba.core.xml.load_dict)
				copy!(load_file, mitsuba.core.xml.load_file)
				copy!(load_string, mitsuba.core.xml.load_string)
				return mitsuba
			end
		end
	end
end

end # module
