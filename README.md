
This package brings the [Mitsuba 2](https://www.mitsuba-renderer.org/) renderer to Julia using [PyCall.jl](https://github.com/JuliaPy/PyCall.jl).

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

