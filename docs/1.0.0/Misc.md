Update 1.0.0/Misc.md
88b07c7
1.0.0\Misc.md
@@ -0,0 +1,703 @@
# Types

A particle type constructor that uses similar properties found in GM's part_type family of functions.

## `Type(tag, [gml_type])` (*constructor*)
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

## `TypeTagGetData(tag)` → *Pollen.Type <span style="color: red;"> *or* </span> undefined*
Get the data associated with a Pollen.Type tag (or undefined if data does not exist for the tag)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`tag` |string |The tag of the Pollen.Type that you want to get the data for |

## `TypeDestroy(type)` → `undefined`
Destroys a Pollen.Type and clears all of its data (including the GM part_type it holds)

## `TypeDestroyAll()` → `undefined`
Destroys all Pollen.Types that exist and clears all their data
# Emitters

A particle emitter constructor that uses similar properties found in GM's part_emitter family of functions.

## `Emitter(system, [gml_emitter])` (*constructor*)
A Pollen object that represents GM's part emitters with additional util functions to simplify building emitters and getting their data

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system` |Pollen.System |The Pollen.System the emitter is tied to |
|`[gml_emitter]` |Id.ParticleEmitter|undefined |An optional reference to a GML part emitter you can pass in to initialize the emitter with (i.e. with part_emitter_create(). Defaults to 'undefined') |

























**Methods**
### `.SetEnabled(enabled)` → *self*
Whether to enable the emitter to emit particles or not

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`enabled` |bool |True to enable, false to disable |

### `.SetType(type)` → *self*
Sets the particle type emitted (Pollen.Type instance or tag)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`type` |struct|string|undefined |The type struct or tag, or undefined to clear |

### `.SetNumber(number)` → *self*
Sets how many particles this emitter creates per burst/tick

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`number` |real |The number of particles |

### `.SetShape(shape)` → *self*
Sets the emitter region shape (e.g., ps_shape_rectangle, ps_shape_ellipse)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`shape` |ps_shape |The emitter shape constant |

### `.SetDistr(distr)` → *self*
Sets the particle distribution shape within the emitter region (e.g., ps_distr_linear)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`distr` |ps_distr |The distribution constant |

### `.SetRelative(enabled)` → *self*
Toggles whether the number of particles (changed via .SetNumber) is an exact number or a relative percentage of emitter area filled
(see "part_emitter_relative" in GM manual for more info)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`enabled` |bool |True for relative, false for absolute |

### `.SetDelay(delay)` → *self*
Sets the initial delay before emission begins when streaming a particle

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`delay` |struct |A struct containing the following properties {min, max, unit} |

### `.SetInterval(interval)` → *self*
Sets the interval between emissions when streaming a particle

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`interval` |struct |A struct containing the following properties {min, max, unit} |

### `.SetSize(width, height)` → *self*
Sets the emitter region size

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`width` |real |The emitter width |
|`height` |real |The emitter height |

### `.SetWidth(width)` → *self*
Sets the emitter region width

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`width` |real |The emitter width |

### `.SetHeight(height)` → *self*
Sets the emitter region height

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`height` |real |The emitter height |

### `.SetOffset(offsetX, offsetY)` → *self*
Sets the emitter offset from its origin

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`offsetX` |real |Horizontal offset |
|`offsetY` |real |Vertical offset |

### `.SetOffsetX(offsetX)` → *self*
Sets only the horizontal emitter offset

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`offsetX` |real |Horizontal offset |

### `.SetOffsetY(offsetY)` → *self*
Sets only the vertical emitter offset

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`offsetY` |real |Vertical offset |

### `.GetGmlData()` → *Id.Emitter*
Returns the underlying GM emitter handle used by the system

### `.GetSystem()` → *Pollen.System*
Returns the parent Pollen.System that owns this emitter

### `.IsEnabled()` → *bool*
Returns whether the emitter is enabled

### `.GetEnabled()` → *bool*
Alias for IsEnabled(); returns whether the emitter is enabled

### `.GetType()` → *struct <span style="color: red;"> *or* </span> string <span style="color: red;"> *or* </span> undefined*
Returns the particle type set on this emitter (struct or tag), or undefined

### `.GetNumber()` → *real*
Returns the number of particles emitted per burst/tick

### `.GetShape()` → *ps_shape <span style="color: red;"> *or* </span> undefined*
Returns the emitter region shape constant

### `.GetDistr()` → *bool*
Returns the emitter distribution

### `.GetRelative()` → *bool*
Returns whether the emitter is emitting exact number of particles (true) or a relative percentage (false)

### `.GetDelay()` → *struct*
Returns the initial delay settings for streaming {min, max, unit}

### `.GetInterval()` → *struct*
Returns the interval settings for streaming {min, max, unit}

### `.GetSize()` → *struct*
Returns the emitter region size as a struct {w, h}

### `.GetWidth()` → *real*
Returns the emitter region width

### `.GetHeight()` → *real*
Returns the emitter region height

### `.GetOffset()` → *struct*
Returns the emitter offset as a struct {x, y}

### `.GetOffsetX()` → *real*
Returns the horizontal emitter offset

### `.GetOffsetY()` → *real*
Returns the vertical emitter offset

## `EmitterDestroy(emitter)` → `undefined`
Destroys a single Pollen.Emitter and clears all of its data (including its underlying GM part_emitter data)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`emitter` |Pollen.Emitter |The Pollen.Emitter data to destroy |
# System

A particle system constructor that uses similar properties found in GM's part_system family of functions.

## `System(tag, [gml_system])` (*constructor*)
A Pollen object that represents GM's part systems with additional util functions to simplify building systems and getting their data

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`tag` |string |A unique tag used to identity the system |
|`[gml_system]` |Id.ParticleType|undefined |An optional reference to a GML part system you can pass in to initialize the type with (i.e. with part_system_create(). Defaults to 'undefined') |



























**Methods**
### `.SetTemplate(template, [copy_on_set])` → *self*
Sets the template that the system will default to

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`template` |string|Pollen.System|undefined |The tag or Pollen.Instance to set the template as, or set as 'undefined' clear the template |

### `.SetEmitterList(list)` → *self*
Replaces the system's emitter list with the provided array; destroys existing emitters first

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`list` |array |The new list of Pollen.Emitter instances |

### `.SetColor(color)` → *self*
Sets a color multiplier applied to all particles rendered by this system

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`color` |color |The color (e.g., c_white) |

### `.SetAlpha(alpha)` → *self*
Sets the alpha multiplier applied to all particles rendered by this system

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`alpha` |real |The alpha value (0..1) |

### `.SetPosition([x], [y])` → *self*
Sets the system's origin position

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`[x]` |real|undefined |X position (or undefined to keep current) |
|`[y]` |real|undefined |Y position (or undefined to keep current) |

### `.SetGlobalSpace(enabled)` → *self*
Toggles whether particle positions maintain their global/room position or are set local/relative to the system's position

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`enabled` |bool |True for global space, false for local |

### `.SetDrawOrder(enabled)` → *self*
Sets draw order to old-to-new (true) or new-to-old (false)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`enabled` |bool |Draw oldest first when true |

### `.SetAngle(angle)` → *self*
Sets a rotation applied to all particles during rendering

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`angle` |real |Angle in degrees |

### `.SetDepth(depth)` → *self*
Sets the draw depth for the system and clears any layer binding

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`depth` |real|undefined |The new depth (smaller = in front) |

### `.SetLayer(layer)` → *self*
Binds the system to a room layer (overrides depth)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`layer` |string|real|undefined |The room layer name or ID |

### `.GetTag()` → *string*
Returns the unique system tag

### `.GetGmlData()` → *Id.ParticleSystem*
Returns the underlying GM particle system handle

### `.GetGmlData()` → *string <span style="color: red;"> *or* </span> Id.ParticleSystem <span style="color: red;"> *or* </span> undefined*
Returns the part system template the Pollen.System copies from

### `.GetDepth()` → *real*
Returns the system's draw depth (ignored when layer is set)

### `.GetLayer()` → *string <span style="color: red;"> *or* </span> real <span style="color: red;"> *or* </span> undefined*
Returns the bound room layer name/ID, or undefined if unbound

### `.GetPosition()` → *struct*
Returns the system position as a struct {x, y}

### `.GetGlobalSpace()` → *bool*
Returns whether the system uses global space

### `.GetDrawOrder()` → *bool*
Returns whether oldest particles are drawn first

### `.GetAngle()` → *real*
Returns the render rotation angle in degrees

### `.GetColor()` → *color*
Returns the color multiplier applied to particles

### `.GetAlpha()` → *real*
Returns the alpha multiplier applied to particles

### `.GetEmitterList()` → *array*
Returns the array of emitters owned by this system

### `.RefreshStream()` → `undefined`
Rebuilds and restarts the system's streaming emitters if streaming is active

### `.Copy(pfx, [ignore_emitter_list])` → `undefined`
Copies configuration from another Pollen.System into this system

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`pfx` |Pollen.System |The source system to copy from |
|`[ignore_emitter_list]` |bool |If true, skips copying the emitter list |

## `SystemTagGetData(tag)` → *Pollen.System <span style="color: red;"> *or* </span> undefined*
Get the data associated with a Pollen.System tag (or undefined if data does not exist for the tag)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`tag` |string |The tag of the Pollen.System that you want to get the data for |

## `EmitterListDestroyAll(system)` → `undefined`
Destroys all the emitters tied to a Pollen.System

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system` |Pollen.System |The system to clear the emitters from |

## `SystemDestroy(system)` → `undefined`
Destroys a single Pollen.System instance and clears all of its data (including its underlying GM part_system data)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system` |Pollen.System |The Pollen.System instance to destroy |

## `SystemDestroyAll()` → `undefined`
Destroys all instances of Pollen.System and clears all of their data
# Create Particles

Use these methods to create particles in game.

## `Stream(system_or_tag, [x_offset], [y_offset], [amount])` → `undefined`
Starts continuous streaming from all enabled emitters in a system. If `amount` is provided, it overrides each emitter's particle count.

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system_or_tag` |Pollen.System|string |The Pollen system instance or its string tag |
|`[x_offset]` |real |An optional horizontal offset to apply to emission position (i.e. relative to particle system position) |
|`[y_offset]` |real |An optional vertical offset to apply to emission position (i.e. relative to particle system position) |
|`[amount]` |real|undefined |Optional particles-per-step override for all emitters |

## `Burst(system_or_tag, [x_offset], [y_offset], [amount])` → `undefined`
Emits a single burst from all enabled emitters in a system. If `amount` is provided, it overrides each emitter's particle count.

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system_or_tag` |Pollen.System|string |The Pollen system instance or its string tag |
|`[x_offset]` |real |An optional horizontal offset to apply to emission position (i.e. relative to particle system position. Defaults to 0) |
|`[y_offset]` |real |An optional vertical offset to apply to emission position (i.e. relative to particle system position. Defaults to 0) |
|`[amount]` |real|undefined |Optional particles-per-step override for all emitters (Defaults to undefined) |
# Import particles

Use these methods to import particle data into Pollen.

## `ImportPfx(data)` → `undefined`
Import data from a GML 'JSON' array (see info about setting up 'JSON' in the 'Config JSON' section of the manual)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`data` |array |The array to parse and import data from |

## `ImportType(import_data, type_data)` → `undefined`
Copy data from a GML 'JSON' type struct into a Pollen.Type instance (see info about setting up 'JSON' in the 'Config JSON' section of the manual)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`import_data` |struct |The struct to parse and import data from |
|`type_data` |Pollen.Type |The Pollen.Type instance to copy the data to |

## `ConvertGmlPartAssetToPollenStruct(asset, pollen_system, [ignore_emitter_list])` → *Pollen.System*
Copy data from a GML part system *asset* (created using GM's particle editor) into a Pollen.System instance
# Misc

Additional util methods.

## `DestroyAll()` → `undefined`
Destroys all Pollen Types, Emitters, & Systems and clears all their data.