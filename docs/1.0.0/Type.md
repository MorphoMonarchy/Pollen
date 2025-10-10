# Types

A particle type constructor that uses similar properties found in GM's part_type family of functions.

### `Type(tag, [gml_type])` (*constructor*)
A Pollen object that represents GM's part types with additional util functions to simplify building types and getting their data.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `tag` | string | A unique tag used to identify the type |
| `[gml_type]` | Id.ParticleType | An optional reference to a GML part type you can pass in to initialize the type with (i.e. with part_type_create(). Defaults to `undefined`) |

## Methods

### `.GetTag()` → `string`
Returns the unique tag used to identify the type.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetGmlData()` → `Id.ParticleType`
Returns the GML part type data that the Pollen type uses in the backend.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.GetShape()` → `pt_shape or undefined`
Returns the part type shape that is being used or undefined if in sprite mode.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetShape(shape)` → `self`
Sets the shape to a GM part type shape (i.e. `pt_shape_snow`, etc.) instead of a sprite.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `shape` | pt_shape | The `pt_shape` to set the type to |

### `.GetSpriteData()` → `struct or undefined`
Returns the current sprite configuration for the type or undefined if using a primitive shape instead.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetSprite(sprite, [sub_img], [animate], [stretch], [random_img])` → `self`
Sets the particle to use a sprite instead of a `pt_shape`.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `sprite` | sprite | The sprite asset to render for particles |
| `[sub_img]` | real | The starting subimage index |
| `[animate]` | bool | Whether the sprite should animate |
| `[stretch]` | bool | Whether the sprite should stretch its animation across the life of the particle |
| `[random_img]` | bool | Whether to use a random subimage |

### `.GetSize()` → `struct or undefined`
Returns the uniform size configuration or undefined if using axis-specific sizes.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetSize([min], [max], [incr], [wiggle])` → `self`
Sets uniform particle size parameters for both axes and clears axis-specific settings.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum size |
| `[max]` | real | The maximum size |
| `[incr]` | real | The size increment per step |
| `[wiggle]` | real | The random variation applied to size |

### `.GetSizeX()` → `struct or undefined`
Returns the X-axis size configuration or undefined if using uniform size.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetSizeX(min, max, incr, wiggle)` → `self`
Sets size parameters for the X-axis and clears uniform size.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum X size |
| `[max]` | real | The maximum X size |
| `[incr]` | real | The X size increment per step |
| `[wiggle]` | real | The random variation applied to X size |

### `.GetSizeY()` → `struct or undefined`
Returns the Y-axis size configuration or undefined if using uniform size.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetSizeY([min], [max], [incr], [wiggle])` → `self`
Sets size parameters for the Y-axis and clears uniform size.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum Y size |
| `[max]` | real | The maximum Y size |
| `[incr]` | real | The Y size increment per step |
| `[wiggle]` | real | The random variation applied to Y size |

### `.GetScale()` → `struct`
Returns the current particle render scale (x & y).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetScale(x, y)` → `self`
Sets the particle render scale on each axis.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[x]` | real | The horizontal scale factor |
| `[y]` | real | The vertical scale factor |

### `.GetSpeed()` → `struct`
Returns the speed configuration for particles.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetSpeed([min], [max], [incr], [wiggle])` → `self`
Sets the particle speed configuration.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum speed |
| `[max]` | real | The maximum speed |
| `[incr]` | real | The speed increment per step |
| `[wiggle]` | real | The random variation applied to speed |

### `.GetDirection()` → `struct`
Returns the emission direction parameters.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetDirection([min], [max], [incr], [wiggle])` → `self`
Sets the emission direction range and dynamics.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum direction (degrees) |
| `[max]` | real | The maximum direction (degrees) |
| `[incr]` | real | The direction increment per step (degrees) |
| `[wiggle]` | real | The random variation applied to direction |

### `.GetGravity()` → `struct`
Returns the gravity settings (amount and direction).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetGravity([amount], [direction])` → `self`
Sets the gravity amount and direction applied to particles.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[amount]` | real | The gravity strength |
| `[direction]` | real | The gravity direction in degrees |

### `.GetOrientation()` → `struct`
Returns the image orientation parameters.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetOrientation([min], [max], [incr], [wiggle], [relative])` → `self`
Sets the image orientation range and whether it tracks particle direction.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum image angle |
| `[max]` | real | The maximum image angle |
| `[incr]` | real | The angle increment per step |
| `[wiggle]` | real | The random variation applied to angle |
| `[relative]` | bool | Whether to orient relative to motion |

### `.GetColorMix()` → `array<color> or undefined`
Returns the two-color mix array if set, otherwise undefined.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetColorMix(colors_or_array)` → `self`
Sets a two-color gradient mix for particles (accepts two arguments or an array of colors).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `colors_or_array` | array<color> | Two colors as an array, or pass as two separate arguments |

### `.GetColorRgb()` → `struct or undefined`
Returns the RGB range configuration or undefined if not set.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetColorRgb(rmin, rmax, gmin, gmax, bmin, bmax)` → `self`
Sets randomized RGB color channel ranges for particles.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `rmin` | real | Minimum red channel (0–255) |
| `rmax` | real | Maximum red channel (0–255) |
| `gmin` | real | Minimum green channel (0–255) |
| `gmax` | real | Maximum green channel (0–255) |
| `bmin` | real | Minimum blue channel (0–255) |
| `bmax` | real | Maximum blue channel (0–255) |

### `.GetColorHsv()` → `struct or undefined`
Returns the HSV range configuration or undefined if not set.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetColorHsv(hmin, hmax, smin, smax, vmin, vmax)` → `self`
Sets randomized HSV color ranges for particles.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `hmin` | real | Minimum hue (0–255) |
| `hmax` | real | Maximum hue (0–255) |
| `smin` | real | Minimum saturation (0–255) |
| `smax` | real | Maximum saturation (0–255) |
| `vmin` | real | Minimum value/brightness (0–255) |
| `vmax` | real | Maximum value/brightness (0–255) |

### `.GetColor()` → `color or array<color>`
Returns the standard color configuration (single, two, or three colors) if set.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetColor(color_or_array)` → `self`
Sets standard color using one, two, or three colors; accepts a single color or an array of up to three colors.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `color_or_array` | color or array<color> | A single color or an array of colors (1–3 entries) |

### `.GetAlpha()` → `real or array<real>`
Returns the alpha (opacity) configuration (single, two, or three values).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetAlpha(alpha_or_array)` → `self`
Sets alpha (opacity) using one, two, or three values; accepts a single number or an array.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `alpha_or_array` | real or array<real> | A single alpha value or an array (1–3 entries) |

### `.GetBlend()` → `bool`
Returns whether additive blending is enabled for this particle type.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetBlend(enable)` → `self`
Enables or disables additive blending for particles.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `enable` | bool | True to enable additive blending, false for normal blending |

### `.GetLife()` → `struct`
Returns the particle lifetime range in steps.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetLife([min], [max])` → `self`
Sets the particle lifetime range in steps.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[min]` | real | The minimum lifetime (steps) |
| `[max]` | real | The maximum lifetime (steps) |

### `.GetStep()` → `struct`
Returns the sub-particle step emission settings.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetStep([number], [type])` → `self`
Emits sub-particles every given number of steps using the specified type.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[number]` | real | The step interval between emissions |
| `[type]` | struct or string or undefined | The sub-particle type (Pollen.Type instance, tag, or undefined) |

### `.GetDeath()` → `struct`
Returns the sub-particle death emission settings.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `.SetDeath([number], [type])` → `self`
Emits sub-particles upon death using the specified type and particle count.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `[number]` | real | The number of sub-particles to create on death |
| `[type]` | struct or string or undefined | The sub-particle type (Pollen.Type instance, tag, or undefined) |

### `.Copy()` → `undefined`
Copies all configurable properties from another `Pollen.Type` into this type.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `target` | Pollen.Type | The source type to copy from |

## Additional Util Functions

### `TypeTagGetData(tag)` → `Pollen.Type or undefined`
Gets the data associated with a `Pollen.Type` tag (or undefined if data does not exist for the tag).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `tag` | string | The tag of the `Pollen.Type` that you want to get the data for |

### `TypeDestroy(type)` → `undefined`
Destroys a `Pollen.Type` and clears all of its data (including the GM part_type it holds).

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `type` | Pollen.Type | The `Pollen.Type` that you want to destroy |

### `TypeDestroyAll()` → `undefined`
Destroys all `Pollen.Types` that exist and clears all their data.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |