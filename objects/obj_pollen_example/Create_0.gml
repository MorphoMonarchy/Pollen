
system = Pollen.SystemTagGetData("system_example");
template = Pollen.SystemTagGetData("system_template_example");
Pollen.Stream("system_example"); //<--- You can also enter the variable "system" without quotes which is a bit faster (see example in "Global Left Down" event)


//--- BUILDER EXAMPLE ---// <---(uncomment code in "Global Left Down" event to see the particles in runtime)

//Particle Types
typeSmoke = new Pollen.Type("type_smoke")
    .SetShape(pt_shape_smoke)
    .SetColor([c_black, c_dkgray, c_gray])
    .SetAlpha([0.75, 0.5, 0])
    .SetSize(0.3, 0.5, , 0.05) //<---skip "incr" since it's not needed
    .SetSpeed(1, 3, -0.05)
    .SetDirection(80, 100);


//Particle Systems
sysSmoke = new Pollen.System("sys_smoke");
sysSmoke
    .SetDepth(50)
	.SetGlobalSpace(true)
    .SetEmitterList([
        new Pollen.Emitter(sysSmoke)
            .SetType("type_smoke")
            .SetSize(32, 32)
			.SetOffset(0, -12)
            .SetNumber(10)
    ]);

//--- TEST ---//
show_debug_overlay(true);
 //__enable = true;
// __id = 0;