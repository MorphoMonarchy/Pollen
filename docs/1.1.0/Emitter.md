# Emitters

A particle emitter constructor that uses similar properties found in GM's part_emitter family of functions.

### `Emitter(system, [gml_emitter])` (*constructor*)
A Pollen object that represents GM's part emitters with additional util functions to simplify building emitters and getting their data.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `system` | Pollen.System | The Pollen.System the emitter is tied to |
| `[gml_emitter]` | Id.ParticleEmitter | An optional reference to a GML part emitter you can pass in to initialize the emitter with (i.e. with `part_emitter_create()`. Defaults to `undefined`) |

## Methods

### `.SetEnabled(enabled)` → `self`
Whether to enable the emitter to emit particles or not.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `enabled` | bool | True to enable, false to disable |

### `.SetType(type)` → `self`
Sets the particle type emitted (Pollen.Type instance or tag).

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `type` | struct or string or undefined | The type struct or tag, or `undefined` to clear |

### `.SetNumber(number)` → `self`
Sets how many particles this emitter creates per burst/tick.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `number` | real | The number of particles |

### `.SetShape(shape)` → `self`
Sets the emitter region shape (e.g., `ps_shape_rectangle`, `ps_shape_ellipse`).

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `shape` | ps_shape | The emitter shape constant |

### `.SetDistr(distr)` → `self`
Sets the particle distribution shape within the emitter region (e.g., `ps_distr_linear`).

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `distr` | ps_distr | The distribution constant |

### `.SetRelative(enabled)` → `self`
Toggles whether the number of particles (changed via `.SetNumber`) is an exact number or a relative percentage of emitter area filled (see `part_emitter_relative` in the GM manual for more info).

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `enabled` | bool | True for relative, false for absolute |

### `.SetDelay(delay)` → `self`
Sets the initial delay before emission begins when streaming a particle.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `delay` | struct | A struct containing the following properties `{min, max, unit}` |

### `.SetInterval(interval)` → `self`
Sets the interval between emissions when streaming a particle.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `interval` | struct | A struct containing the following properties `{min, max, unit}` |

### `.SetSize(width, height)` → `self`
Sets the emitter region size.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `width` | real | The emitter width |
| `height` | real | The emitter height |

### `.SetWidth(width)` → `self`
Sets the emitter region width.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `width` | real | The emitter width |

### `.SetHeight(height)` → `self`
Sets the emitter region height.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `height` | real | The emitter height |

### `.SetOffset(offsetX, offsetY)` → `self`
Sets the emitter offset from its origin.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `offsetX` | real | Horizontal offset |
| `offsetY` | real | Vertical offset |

### `.SetOffsetX(offsetX)` → `self`
Sets only the horizontal emitter offset.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `offsetX` | real | Horizontal offset |

### `.SetOffsetY(offsetY)` → `self`
Sets only the vertical emitter offset.

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `offsetY` | real | Vertical offset |

### `.GetGmlData()` → `Id.Emitter`
Returns the underlying GM emitter handle used by the system.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetSystem()` → `Pollen.System`
Returns the parent Pollen.System that owns this emitter.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.IsEnabled()` → `bool`
Returns whether the emitter is enabled.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetEnabled()` → `bool`
Alias for `IsEnabled()`; returns whether the emitter is enabled.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetType()` → `struct or string or undefined`
Returns the particle type set on this emitter (struct or tag), or `undefined`.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetNumber()` → `real`
Returns the number of particles emitted per burst/tick.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetShape()` → `ps_shape or undefined`
Returns the emitter region shape constant.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetDistr()` → `bool`
Returns the emitter distribution.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetRelative()` → `bool`
Returns whether the emitter is emitting exact number of particles (true) or a relative percentage (false).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetDelay()` → `struct`
Returns the initial delay settings for streaming `{min, max, unit}`.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetInterval()` → `struct`
Returns the interval settings for streaming `{min, max, unit}`.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetSize()` → `struct`
Returns the emitter region size as a struct `{w, h}`.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetWidth()` → `real`
Returns the emitter region width.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetHeight()` → `real`
Returns the emitter region height.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetOffset()` → `struct`
Returns the emitter offset as a struct `{x, y}`.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetOffsetX()` → `real`
Returns the horizontal emitter offset.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetOffsetY()` → `real`
Returns the vertical emitter offset.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

## Additional Util Functions

### `EmitterDestroy(emitter)` → `undefined`
Destroys a single `Pollen.Emitter` and clears all of its data (including its underlying GM `part_emitter` data).

| Parameter | Datatype | Purpose |
|-----------|----------|---------|
| `emitter` | Pollen.Emitter | The `Pollen.Emitter` data to destroy |

### `EmitterReset(emitter)` → `undefined`
Resets all the underlying data of a part emitter to default settings similar to GM's 'part_emitter_clear' function. **NOTE: does not clear visual representation of particles, and if an emitter is streaming particles, it will stop and have to be restarted using Pollen.Stream()**

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `emitter` | Pollen.Emitter | The `Pollen.Emitter` data that you want to reset |