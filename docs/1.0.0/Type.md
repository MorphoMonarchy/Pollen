# Types

A particle type constructor that uses similar properties found in GM's part_type family of functions.

### `Type(tag, [gml_type])` (*constructor*)
A Pollen object that represents GM's part types with additional util functions to simplify building types and getting their data

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`tag` |string |A unique tag used to identity the type |
|`[gml_type]` |Id.ParticleType|undefined |An optional reference to a GML part type you can pass in to initialize the type with (i.e. with part_type_create(). Defaults to 'undefined') |













**Methods**
### `.GetTag()` → *string*
Returns the unique tag used to identify the type

### `.GetGmlData()` → *Id.ParticleType*
Returns the gml part type data that the Pollen type uses in the backend

### `.GetShape()` → *pt_shape?*
Returns the part type shape that is being used or undefined if in sprite mode

### `.SetShape(shape)` → *self*
Sets the shape to a GM part type shape (i.e. pt_shape_snow, etc.) instead of a sprite

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`shape` |pt_shape |The pt_shape to set the type to |

### `.GetSpriteData()` → *struct?*
Returns the current sprite configuration for the type or undefined if using a primitive shape

### `.SetSprite(sprite, [sub_img], [animate], [stretch], [random_img])` → *self*
Sets the particle to use a sprite instead of a pt_shape

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`sprite` |sprite |The sprite asset to render for particles |
|`[sub_img]` |real |The starting subimage index |
|`[animate]` |bool |Whether the sprite should animate |
|`[stretch]` |bool |Whether the sprite should stretch its animation across the life of the particle |
|`[random_img]` |bool |Whether to use a random subimage |

### `.GetSize()` → *struct?*
Returns the uniform size configuration or undefined if using axis-specific sizes

### `.SetSize([min], [max], [incr], [wiggle])` → *self*
Sets uniform particle size parameters for both axes and clears axis-specific settings

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum size |
|`[max]` |real |The maximum size |
|`[incr]` |real |The size increment per step |
|`[wiggle]` |real |The random variation applied to size |

### `.GetSizeX()` → *struct?*
Returns the X-axis size configuration or undefined if using uniform size

### `.SetSizeX(min, max, incr, wiggle)` → *self*
Sets size parameters for the X-axis and clears uniform size

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum X size |
|`[max]` |real |The maximum X size |
|`[incr]` |real |The X size increment per step |
|`[wiggle]` |real |The random variation applied to X size |

### `.GetSizeY()` → *struct?*
Returns the Y-axis size configuration or undefined if using uniform size

### `.SetSizeY([min], [max], [incr], [wiggle])` → *self*
Sets size parameters for the Y-axis and clears uniform size

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum Y size |
|`[max]` |real |The maximum Y size |
|`[incr]` |real |The Y size increment per step |
|`[wiggle]` |real |The random variation applied to Y size |

### `.GetScale()` → *struct*
Returns the current particle render scale (x & y)

### `.SetScale(x, y)` → *self*
Sets the particle render scale on each axis

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[x]` |real |The horizontal scale factor |
|`[y]` |real |The vertical scale factor |

### `.GetSpeed()` → *struct*
Returns the speed configuration for particles

### `.SetSpeed([min], [max], [incr], [wiggle])` → *self*
Sets the particle speed range and dynamics

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum speed |
|`[max]` |real |The maximum speed |
|`[incr]` |real |The speed increment per step |
|`[wiggle]` |real |The random variation applied to speed |

### `.GetDirection()` → *struct*
Returns the emission direction parameters

### `.SetDirection([min], [max], [incr], [wiggle])` → *self*
Sets the emission direction range and dynamics

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum direction (degrees) |
|`[max]` |real |The maximum direction (degrees) |
|`[incr]` |real |The direction increment per step (degrees) |
|`[wiggle]` |real |The random variation applied to direction |

### `.GetGravity()` → *struct*
Returns the gravity settings (amount and direction)

### `.SetGravity([amount], [direction])` → *self*
Sets the gravity amount and direction applied to particles

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[amount]` |real |The gravity strength |
|`[direction]` |real |The gravity direction in degrees |

### `.GetOrientation()` → *struct*
Returns the image orientation parameters

### `.SetOrientation([min], [max], [incr], [wiggle], [relative])` → *self*
Sets the image orientation range and whether it tracks particle direction

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum image angle |
|`[max]` |real |The maximum image angle |
|`[incr]` |real |The angle increment per step |
|`[wiggle]` |real |The random variation applied to angle |
|`[relative]` |bool |Whether to orient relative to motion |

### `.GetColorMix()` → *array<color>?*
Returns the two-color mix array if set, otherwise undefined

### `.SetColorMix(colors_or_array)` → *self*
Sets a two-color gradient mix for particles (accepts two arguments or an array of colors)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`colors_or_array` |array<color>|color |Two colors as an array, or pass as two separate arguments |

### `.GetColorRgb()` → *struct?*
Returns the RGB range configuration or undefined if not set

### `.SetColorRgb(rmin, rmax, gmin, gmax, bmin, bmax)` → *self*
Sets randomized RGB color channel ranges for particles

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`rmin` |real |Minimum red channel (0–255) |
|`rmax` |real |Maximum red channel (0–255) |
|`gmin` |real |Minimum green channel (0–255) |
|`gmax` |real |Maximum green channel (0–255) |
|`bmin` |real |Minimum blue channel (0–255) |
|`bmax` |real |Maximum blue channel (0–255) |

### `.GetColorHsv()` → *struct?*
Returns the HSV range configuration or undefined if not set

### `.SetColorHsv(hmin, hmax, smin, smax, vmin, vmax)` → *self*
Sets randomized HSV color ranges for particles

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`hmin` |real |Minimum hue (0–255) |
|`hmax` |real |Maximum hue (0–255) |
|`smin` |real |Minimum saturation (0–255) |
|`smax` |real |Maximum saturation (0–255) |
|`vmin` |real |Minimum value/brightness (0–255) |
|`vmax` |real |Maximum value/brightness (0–255) |

### `.GetColor()` → *color <span style="color: red;"> *or* </span> array<color>*
Returns the standard color configuration (single, two, or three colors) if set

### `.SetColor(color_or_array)` → *self*
Sets standard color using one, two, or three colors; accepts a single color or an array of up to three colors

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`color_or_array` |color|array<color> |A single color or an array of colors (1–3 entries) |

### `.GetAlpha()` → *real <span style="color: red;"> *or* </span> array<real>*
Returns the alpha (opacity) configuration (single, two, or three values)

### `.SetAlpha(alpha_or_array)` → *self*
Sets alpha (opacity) using one, two, or three values; accepts a single number or an array

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`alpha_or_array` |real|array<real> |A single alpha value or an array (1–3 entries) |

### `.GetBlend()` → *bool*
Returns whether additive blending is enabled for this particle type

### `.SetBlend(enable)` → *self*
Enables or disables additive blending for particles

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`enable` |bool |True to enable additive blending, false for normal blending |

### `.GetLife()` → *struct*
Returns the particle lifetime range in steps

### `.SetLife([min], [max])` → *self*
Sets the particle lifetime range in steps

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[min]` |real |The minimum lifetime (steps) |
|`[max]` |real |The maximum lifetime (steps) |

### `.GetStep()` → *struct*
Returns the sub-particle step emission settings

### `.SetStep([number], [type])` → *self*
Emits sub-particles every given number of steps using the specified type

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[number]` |real |The step interval between emissions |
|`[type]` |struct|string|undefined |The sub-particle type (Pollen.Type instance, tag, or undefined) |

### `.GetDeath()` → *struct*
Returns the sub-particle death emission settings

### `.SetDeath([number], [type])` → *self*
Emits sub-particles upon death using the specified type and particle count

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[number]` |real |The number of sub-particles to create on death |
|`[type]` |struct|string|undefined |The sub-particle type (Pollen.Type instance, tag, or undefined) |

### `.Copy()` → `undefined`
Copies all configurable properties from another Pollen.Type into this type

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`target` |Pollen.Type |The source type to copy from |

### `TypeTagGetData(tag)` → *Pollen.Type <span style="color: red;"> *or* </span> undefined*
Get the data associated with a Pollen.Type tag (or undefined if data does not exist for the tag)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`tag` |string |The tag of the Pollen.Type that you want to get the data for |

### `TypeDestroy(type)` → `undefined`
Destroys a Pollen.Type and clears all of its data (including the GM part_type it holds)

### `TypeDestroyAll()` → `undefined`
Destroys all Pollen.Types that exist and clears all their data