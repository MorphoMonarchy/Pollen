# Configure PFX

## Introduction

Pollen can import GML 'JSON' that represents the **particle effects setup** for your game. This works similarly to the 'JSON' setup in JuJuAdams' [Vinyl](https://www.jujuadams.com/Vinyl/#). You can define the JSON that Pollen should load automatically on startup by editing the script **`scr_pollen_config_pfx()`**. You can also manually import JSON at runtime using helper functions such as `Pollen.ImportPFX()` and `Pollen.ImportType()`. 

Using JSON configuration is **optional**. All JSON imports are simply shorthand for calling the same setup functions that Pollen executes internally. If you prefer, you can manually configure particle systems, emitters, and types through code using `Pollen.Type`, `Pollen.Emitter`, and `Pollen.System` constructors without any loss of functionality.

Pollen JSON definitions can include **types**, **systems**, and **emitters**. The root of a Pollen JSON file should be an **array**, and each entry in that array should be a struct defining one of those objects. Emitters are nested under systems, and types can be referenced in emitters or defined inline.

---

### Example of a Simple Pollen JSON

~~~
    [
        {
            type: "type_smoke",
            sprite: { id: spr_smoke, animate: true },
            color: [#CCCCCC, c_black],
            alpha: [1, 0],
            life: { min: 60, max: 120 },
        },
        {
            system: "sys_smoke",
            globalSpace: true,
            depth: -50,
            emitterList: [
                {
                    type: "type_smoke",
                    number: 10,
                    width: 64,
                    height: 64,
                    shape: ps_shape_rectangle,
                },
            ]
        },
    ]
~~~

In this JSON, there are two Pollen definitions:  
- A **particle type** named `"type_smoke"`, which uses the sprite `spr_smoke`, fades out over time, between 60–120 steps.  
- A **particle system** named `"sys_smoke"`, which contains one emitter that spawns 10 `"type_smoke"` particles per emission from a rectangular area.

The type is referenced by name within the system’s emitter list, allowing you to modularly define and reuse particle types throughout your game.

Pollen’s JSON format provides an easy way to organize, tweak, and iterate on complex effects during development — especially when combined with **live editing** via the `POLLEN_LIVE_EDIT` macro.

# Properties

The following properties that require a struct (such as 'shape' in the 'Types' section below) do not require all possible members to be defined, only members that you want to defer from the default value. For example, if you look at the previous JSON example above, you'll find in the 'sprite' definition of 'type_smoke' that only the 'id' and 'animate' members were defined. So as long as you have the required members defined ('id' for the case of 'sprite'), then the JSON will still be considered valid. 

Please see 'Notes' section of each of the tables for info on which members are required.

## Types

| Property | Datatype | Default | Notes |
|---|---|---|---|
| `type` | string | N/A | **Required.** Unique name to identify the type. |
| `template` | string or undefined | `undefined` | Optional reference template for this type. |
| `shape` | pt_shape or undefined | `pt_shape_pixel` | Particle shape when not using a sprite. |
| `sprite` | struct or undefined | <code>{<br>  &nbsp;&nbsp;id: undefined,<br>  &nbsp;&nbsp;subImg: 0,<br>  &nbsp;&nbsp;animate: false,<br>  &nbsp;&nbsp;stretch: false,<br>  &nbsp;&nbsp;randomImg: false,<br> &nbsp}</code> | Sprite rendering settings for the particle. NOTE: 'id' is **required**|
| `size` | struct or undefined | <code>{<br>  &nbsp;&nbsp;min: 1,<br>  &nbsp;&nbsp;max: 1,<br>  &nbsp;&nbsp;incr: 0,<br>  &nbsp;&nbsp;wiggle: 0,<br> &nbsp}</code> | Uniform particle size range and behavior. |
| `sizeX` | struct or undefined | `undefined` | Axis-specific X size configuration. |
| `sizeY` | struct or undefined | `undefined` | Axis-specific Y size configuration. |
| `scale` | struct | <code>{<br>  &nbsp;&nbsp;x: 1,<br>  &nbsp;&nbsp;y: 1,<br>&nbsp}</code> | Scale multiplier for particle rendering. |
| `speed` | struct | <code>{<br>  &nbsp;&nbsp;min: 0,<br>  &nbsp;&nbsp;max: 0,<br>  &nbsp;&nbsp;incr: 0,<br>  &nbsp;&nbsp;wiggle: 0,<br>&nbsp}</code> | Particle speed range and variation. |
| `direction` | struct | <code>{<br>  &nbsp;&nbsp;min: 0,<br>  &nbsp;&nbsp;max: 0,<br>  &nbsp;&nbsp;incr: 0,<br>  &nbsp;&nbsp;wiggle: 0,<br>&nbsp}</code> | Emission direction range and variation. |
| `gravity` | struct | <code>{<br>  &nbsp;&nbsp;amount: 0,<br>  &nbsp;&nbsp;direction: 270,<br>&nbsp}</code> | Gravity amount and direction applied to particles. |
| `orientation` | struct | <code>{<br>  &nbsp;&nbsp;min: 0,<br>  &nbsp;&nbsp;max: 0,<br>  &nbsp;&nbsp;incr: 0,<br>  &nbsp;&nbsp;wiggle: 0,<br>  &nbsp;&nbsp;relative: false,<br>&nbsp}</code> | Image orientation range and relative behavior. |
| `color` | color or array<color> | `c_white` | Standard color configuration (1–3 colors). Will deactivate 'mix', 'rgb', and 'hsv' modes|
| `colorMix` | array<color> or undefined | `undefined` | Two-color gradient mix for particles. Will deactivate 'standard', 'rgb', and 'hsv' modes|
| `colorRgb` | struct or undefined | `undefined` | Randomized RGB color range settings. Will deactivate 'mix', 'standard', and 'hsv' modes|
| `colorHsv` | struct or undefined | `undefined` | Randomized HSV color range settings. Will deactivate 'mix', 'rgb', and 'standard' modes|
| `alpha` | real or array<real> | `1` | Opacity configuration (single or multi-value). |
| `blend` | bool | `false` | Enables or disables additive blending. |
| `life` | struct | <code>{<br>  &nbsp;&nbsp;min: 100,<br>  &nbsp;&nbsp;max: 100,<br>&nbsp}</code> | Lifetime range of particles in steps. |
| `step` | struct | <code>{<br>  &nbsp;&nbsp;number: 0,<br>  &nbsp;&nbsp;type: undefined,<br>&nbsp}</code> | Sub-particle emission during lifetime. |
| `death` | struct | <code>{<br>  &nbsp;&nbsp;number: 0,<br>  &nbsp;&nbsp;type: undefined,<br>&nbsp}</code> | Sub-particle emission upon death. |

## Systems

| Property | Datatype | Default | Notes |
|---|---|---|---|
| `system` | string | N/A | **Required.** Unique name to identify the system. |
| `template` | string or GM Particle Asset or undefined | `undefined` | Optional reference template for this system. |
| `position` | struct |<code>{<br>  &nbsp;&nbsp;x: 0,<br>  &nbsp;&nbsp;y: 0,<br> &nbsp}</code>| System origin position in the room. |
| `globalSpace` | bool | `false` | Determines if particles use global or local space. |
| `drawOrder` | bool | `true` | When true, older particles are drawn first. |
| `angle` | real | `0` | Global rotation applied to all particles. |
| `depth` | real | `0` | Draw depth for the system. Lower values draw in front. |
| `layer` | string or real or undefined | `undefined` | Room layer name or ID bound to the system. |
| `color` | color | `c_white` | Color multiplier applied to all particles. |
| `alpha` | real | `1` | Alpha (opacity) multiplier applied to all particles. |
| `emitterList` | array<struct> | `[]` | Array of emitter configurations; see 'Emitters' section below. |

## Emitters

| Property | Datatype | Default | Notes |
|---|---|---|---|
| `enabled` | bool | `true` | Determines if the emitter is active and emitting particles. |
| `type` | struct or string or undefined | `undefined` | Particle type to emit (reference or inline definition). |
| `relative` | bool | `false` | When true, emission is relative to emitter area instead of fixed count. NOTE: this must be defined BEFORE defining 'number' below or live changes won't be reflected properly! |
| `number` | real | `1` | Number of particles emitted per burst or tick. |
| `shape` | ps_shape | `ps_shape_ellipse` | Emitter region shape constant. |
| `distr` | ps_distr | `ps_distr_linear` | Distribution pattern for emitted particles. |
| `delay` | struct | <code>{<br>  &nbsp;&nbsp;min: 0,<br>  &nbsp;&nbsp;max: 0,<br>  &nbsp;&nbsp;unit: time_source_units_frames,<br> &nbsp}</code> | Initial delay before emission starts. |
| `interval` | struct | <code>{<br>  &nbsp;&nbsp;min: 0,<br>  &nbsp;&nbsp;max: 0,<br>  &nbsp;&nbsp;unit: time_source_units_frames,<br> &nbsp}</code> | Interval between emissions when streaming. |
| `width` | real | `32` | Emitter region width. |
| `height` | real | `32` | Emitter region height. |
| `offsetX` | real | `0` | Horizontal offset from system origin. |
| `offsetY` | real | `0` | Vertical offset from system origin. |