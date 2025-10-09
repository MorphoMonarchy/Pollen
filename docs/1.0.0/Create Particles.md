# Create Particles

Use these methods to create particles in game.

### `Stream(system_or_tag, [x_offset], [y_offset], [amount])` → `undefined`
Starts continuous streaming from all enabled emitters in a system. If `amount` is provided, it overrides each emitter's particle count.

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system_or_tag` |Pollen.System|string |The Pollen system instance or its string tag |
|`[x_offset]` |real |An optional horizontal offset to apply to emission position (i.e. relative to particle system position) |
|`[y_offset]` |real |An optional vertical offset to apply to emission position (i.e. relative to particle system position) |
|`[amount]` |real|undefined |Optional particles-per-step override for all emitters |

### `Burst(system_or_tag, [x_offset], [y_offset], [amount])` → `undefined`
Emits a single burst from all enabled emitters in a system. If `amount` is provided, it overrides each emitter's particle count.

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system_or_tag` |Pollen.System|string |The Pollen system instance or its string tag |
|`[x_offset]` |real |An optional horizontal offset to apply to emission position (i.e. relative to particle system position. Defaults to 0) |
|`[y_offset]` |real |An optional vertical offset to apply to emission position (i.e. relative to particle system position. Defaults to 0) |
|`[amount]` |real|undefined |Optional particles-per-step override for all emitters (Defaults to undefined) |