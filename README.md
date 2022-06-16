
This package brings the [Mitsuba 2](https://www.mitsuba-renderer.org/) renderer to Julia using [PyCall.jl](https://github.com/JuliaPy/PyCall.jl).

Mitsuba2.jl relies on the `mitsuba` package being available in your local Python installation.
On Arch Linux, this can be done by installing [`mitsuba2-git` from the AUR](https://aur.archlinux.org/packages/mitsuba2-git).
Different distributions of Linux (as well as other OSes like Mac OS and Windows) are un-tested, and may package the `mitsuba` Python module differently.
Testing and feedback are very welcome for this pre-alpha package!

## Example

A simple scene can be rendered with a few commands that closely parallel the Python examples in [the mitsuba documentation](https://mitsuba2.readthedocs.io/en/latest/src/python_interface/intro.html).

```julia
using Mitsuba2
import Mitsuba2.scalar_rgb as mitsuba

scene = mitsuba.load_string(read("test_scene.xml", String))
sensor = first(scene.sensors())
scene.integrator().render(scene, sensor) # true means success
bmp = sensor.film().bitmap(raw=true)
```

![](https://i.imgur.com/yu12tJt.png)

