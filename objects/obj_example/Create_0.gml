
pfx = new Pollen.PFX();

// start streaming a few particles per step
part_emitter_region(pfx.system, pfx.emitterList[0], x - 32, x + 32, y - 32, y + 32, ps_shape_rectangle, ps_distr_linear);
part_emitter_stream(pfx.system, pfx.emitterList[0], pfx.typeList[0], 10);