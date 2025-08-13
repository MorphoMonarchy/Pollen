
pfx = new Pollen.PFX();

// start streaming a few particles per step
part_emitter_region(pfx.system, pfx.emitter, x - 32, x + 32, y - 32, y + 32, ps_shape_rectangle, ps_distr_linear);
part_emitter_stream(pfx.system, pfx.emitter, pfx.type, 10);