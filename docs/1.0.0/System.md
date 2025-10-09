# System

A particle system constructor that uses similar properties found in GM's part_system family of functions.

### `System(tag, [gml_system])` (*constructor*)
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

---

## Additional Util Methods

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`pfx` |Pollen.System |The source system to copy from |
|`[ignore_emitter_list]` |bool |If true, skips copying the emitter list |

### `SystemTagGetData(tag)` → *Pollen.System <span style="color: red;"> *or* </span> undefined*
Get the data associated with a Pollen.System tag (or undefined if data does not exist for the tag)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`tag` |string |The tag of the Pollen.System that you want to get the data for |

### `EmitterListDestroyAll(system)` → `undefined`
Destroys all the emitters tied to a Pollen.System

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system` |Pollen.System |The system to clear the emitters from |

### `SystemDestroy(system)` → `undefined`
Destroys a single Pollen.System instance and clears all of its data (including its underlying GM part_system data)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`system` |Pollen.System |The Pollen.System instance to destroy |

### `SystemDestroyAll()` → `undefined`
Destroys all instances of Pollen.System and clears all of their data