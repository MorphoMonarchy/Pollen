// feather ignore all


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
    .SetEmitterList([
        new Pollen.Emitter(sysSmoke)
            .SetType("type_smoke")
            .SetSize(32, 32)
            .SetNumber(10)
    ]);
    











